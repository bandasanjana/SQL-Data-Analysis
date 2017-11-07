#  Get a list of vendor names
SELECT v.vendor_name, v.vendor_id FROM Vendors;

# Get a list of vendor names and their default payment terms
 SELECT vendor_name, v.vendor_id, t.terms_description, t.terms_due_days FROM Vendors v JOIN Terms t ON v.default_terms_id = t.terms_id ;

# Get a list of account numbers and their descriptions
  SELECT gla.account_number, gla.account_description
FROM general_ledger_accounts gla;

# Get a list of accounts that have invoices associated with them. Include a count of invoice line items for each account. Sort the list to show the account with highest number of invoice line items first.
 SELECT gla.account_number, gla.account_description, count(ili.invoice_id) 
FROM invoice_line_items ili JOIN general_ledger_accounts gla ON ili.account_number = gla.account_number 
GROUP BY 1, 2 
ORDER BY 3 DESC, 2 ASC ;

# Get a list of account numbers and their descriptions that have invoices associated with them
SELECT DISTINCT gla.account_number, gla.account_description
FROM invoice_line_items ili JOIN general_ledger_accounts gla  
ON ili.account_number = gla.account_number 
ORDER BY gla.account_description ;

#Get a list of vendors associated with each account number and description that is associated with an invoice
SELECT DISTINCT gla.account_number, gla.account_description, v.vendor_name 
FROM invoice_line_items ili JOIN general_ledger_accounts gla  
ON ili.account_number = gla.account_number 
    JOIN invoices i ON ili.invoice_id = i.invoice_id 
    JOIN vendors v on i.vendor_id = v.vendor_id 
ORDER BY gla.account_description ;

# Get a count of vendors for each account that is associated with an invoice
SELECT gla.account_number, gla.account_description, count(v.vendor_id) 
FROM invoice_line_items ili JOIN general_ledger_accounts gla  
ON ili.account_number = gla.account_number 
    JOIN invoices i ON ili.invoice_id = i.invoice_id 
    JOIN vendors v on i.vendor_id = v.vendor_id 
GROUP BY gla.account_number 
ORDER BY gla.account_description ;

#Determine the total unpaid amount
    SELECT sum(i.invoice_total-i.credit_total-i.payment_total) AS 'TotalUnpaid Amt' 
FROM invoices i JOIN vendors v ON i.vendor_id = v.vendor_id ;

# Get a breakdown by vendor, of the total unpaid amount for all invoices
   SELECT v.vendor_name, sum(i.invoice_total-i.credit_total-i.payment_total) AS 'Unpaid Amt' 
FROM invoices i JOIN vendors v ON i.vendor_id = v.vendor_id 
GROUP BY v.vendor_name 
ORDER BY 2 DESC ;

#  Get a breakdown by account, of the total unpaid amount for all invoices
    SELECT gla.account_description, sum(i.invoice_total-i.credit_total-i.payment_total) AS 'Unpaid Amt' 
FROM invoices i JOIN invoice_line_items ili ON i.invoice_id = ili.invoice_id 
     JOIN general_ledger_accounts gla ON ili.account_number = gla.account_number 
GROUP BY gla.account_description 
ORDER BY 2 DESC, 1 ASC ;

#  Determine the highest credit amount provided for an invoice
   SELECT max(i3.credit_total) FROM invoices i3;

#   Determine the invoice(s) that received the highest credit amount
SELECT   i2.invoice_id FROM invoices i2 
WHERE i2.credit_total = (SELECT max(i3.credit_total) FROM invoices i3);

#  Determine the vendor(s) that provided the invoice(s) with highest credit amount
    SELECT v.vendor_name, v.vendor_city, v.vendor_state, v.vendor_contact_last_name, v.vendor_contact_first_name
FROM vendors v JOIN invoices i1 ON i1.vendor_id = v.vendor_id 
WHERE i1.invoice_id IN (SELECT i2.invoice_id FROM invoices i2 
WHERE i2.credit_total = (SELECT max(i3.credit_total) FROM invoices i3));

#  Identify the default account description associated with the invoice with highest credit amount
    SELECT DISTINCT gla.account_description 
FROM invoice_line_items ili JOIN invoices i1 ON i1.invoice_id = ili.invoice_id 
     JOIN general_ledger_accounts gla ON ili.account_number = gla.account_number 
WHERE i1.invoice_id IN (SELECT i2.invoice_id FROM invoices i2 
       WHERE i2.credit_total = (SELECT max(i3.credit_total) FROM 
           invoices i3));

# Identify the vendor who provided the highest invoice credit thus far, along with vendor location, and its default account description
   SELECT v.vendor_name, v.vendor_city, v.vendor_state, v.vendor_contact_last_name, v.vendor_contact_first_name, gla.account_description 
FROM vendors v JOIN invoices i1 ON i1.vendor_id = v.vendor_id 
     JOIN general_ledger_accounts gla ON v.default_account_number = gla.account_number 
WHERE i1.invoice_id IN (SELECT i2.invoice_id FROM invoices i2 
WHERE i2.credit_total = (SELECT max(i3.credit_total) FROM invoices i3));



# Provide a list of vendors with name and location that have an average invoice total of at least $1500
    SELECT vendor_id, vendor_name, vendor_city, vendor_state, ROUND(AVG(invoice_total), 2)
    AS average_invoice_amount
FROM invoices JOIN vendors on invoices.vendor_id = vendors.vendor_id
GROUP BY vendor_id
HAVING AVG(invoice_total) > 1500
ORDER BY average_invoice_amount DESC;

#  Provide a count of invoices for each vendor. Include the ones that do not have any invoices
   SELECT vendor_id, vendor_name, count(invoice_id) AS InvoiceCount
FROM vendors LEFT JOIN invoices ON vendors.vendor_id = invoices.vendor_id
GROUP BY vendor_id, vendor_name;

#  Provide a list of vendors that had more than one invoice between June 1 and June 30 of 2014, and had an invoice total of greater than $300
    SELECT invoice_date, COUNT(*) AS invoice_qty, SUM(invoice_total) AS invoice_sum
FROM invoices
GROUP BY invoice_date
HAVING invoice_date BETWEEN '2014-06-01' AND '2014-06-31'
    AND COUNT(*) > 1
    AND SUM(invoice_total) > 300
ORDER BY invoice_date DESC;

#   Provide a list of vendor names and locations that do not have any invoices
   SELECT vendor_id, vendor_name, vendor_state
FROM vendors
WHERE vendor_id NOT IN
    (SELECT DISTINCT vendor_id
     FROM invoices)
ORDER BY vendor_id;

#    Provide a list of invoices with their corresponding balance due (invoice total - payment total - credit total) less than the average unpaid balance for all invoices. Sort them by decreasing balance due amount.
    SELECT invoice_number, invoice_date, invoice_total - payment_total - credit_total AS balance_due
FROM invoices
WHERE invoice_total - payment_total - credit_total  > 0 
  AND invoice_total - payment_total - credit_total <
    (SELECT AVG(invoice_total - payment_total - credit_total)
     FROM invoices
     WHERE invoice_total - payment_total - credit_total > 0)
  ORDER BY invoice_total DESC;

#    Provide a list of invoices with invoice totals having a $ sign before each amount (For example, invoice total of 100 would show as $100 in result set)
    SELECT invoice_total, CONCAT('$', invoice_total)
FROM invoices;


# Write a SELECT statement that returns these columns from the Products table:


SELECT product_name, list_price, date_added
FROM products
WHERE list_price > 500 AND list_price < 2000
ORDER BY date_added DESC;

#  Write a SELECT statement without a FROM clause that uses the NOW function to create a row with these columns:
#today_unformatted    The NOW function unformatted
#today_formatted    The NOW function in this format: 
#DD-Mon-YYYY
#This displays a number for the day, an abbreviation for the month, and a four-digit year.
SELECT NOW() AS today_unformatted,
       DATE_FORMAT(NOW(), '%e-%b-%Y') AS today_formatted;

#   Write a SELECT statement that joins the Customers, Orders, Order_Items, and Products tables. This statement should return these columns: last_name, first_name, order_date, product_name, item_price, discount_amount, and quantity.


SELECT last_name, first_name, order_date, product_name, item_price, discount_amount, quantity
FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  JOIN products p ON oi.product_id = p.product_id
ORDER BY last_name, order_date, product_name ;


# Use the UNION operator to generate a result set consisting of three columns from the Orders table: 

SELECT 'SHIPPED' AS ship_status, order_id, order_date
  FROM orders
  WHERE ship_date IS NOT NULL
UNION
  SELECT 'NOT SHIPPED', order_id, order_date
  FROM orders
  WHERE ship_date IS NULL
ORDER BY order_date;

#Write a SELECT statement that returns one row for each customer that has orders with these columns:

SELECT email_address, COUNT(o.order_id) AS order_count, 
  SUM((item_price - discount_amount) * quantity) AS order_total
FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY email_address
HAVING order_count > 1
ORDER BY order_total DESC;
# Write a SELECT statement that returns these columns from the Products table:

SELECT list_price,
       FORMAT(list_price, 1) AS price_format,
       CONVERT(list_price, SIGNED) AS price_convert, 
       CAST(list_price AS SIGNED) AS price_cast
FROM products;

# Write a SELECT statement that returns the name and discount percent of each product that has a unique discount percent. In other words, don’t include products that have the same discount percent as another product.

SELECT product_name, discount_percent
FROM products
WHERE discount_percent NOT IN (
    SELECT discount_percent
    FROM products
    GROUP BY discount_percent
    HAVING count(discount_percent) > 1)
ORDER BY product_name;

#Use a correlated subquery to return one row per customer, representing the customer’s oldest order (the one with the earliest date). Each row should include these three columns: email_address, order_id, and order_date.
SELECT email_address, order_id, order_date
FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
WHERE order_date =
  (SELECT MIN(order_date)
   FROM orders
   WHERE customer_id = o.customer_id)
GROUP BY email_address;

#Write a SELECT statement that returns these two columns: 
#category_name    The category_name column from the Categories table
#product_id    The product_id column from the Products table
#Return one row for each category that has never been used. Hint: Use an outer join and only return rows where the product_id column contains a null value.

SELECT c.category_name, p.product_id
FROM categories c LEFT JOIN products p
  ON c.category_id = p.category_id
WHERE p.product_id IS NULL;

#Write a SELECT statement that returns these columns from the Orders table:
#The card_number column
#The length of the card_number column
#The last four digits of the card_number column
#When you get that working right, add the columns that follow to the result set. This is more difficult because these columns require the use of functions within functions.
#A column that displays the last four digits of the card_number column in this format: XXXX-XXXX-XXXX-1234. In other words, use Xs for the first 12 digits of the card number and actual numbers for the last four digits of the number.
SELECT card_number, 

       LENGTH(card_number) AS card_number_length, 
       SUBSTRING(card_number, LENGTH(card_number)-3) AS last_four_digits, 
       CONCAT('XXXX-XXXX-XXXX-', SUBSTRING(card_number, LENGTH(card_number)-3)) AS formatted_number
FROM orders;

#Create a view named order_item_products that returns columns from the Orders, Order_Items, and Products tables.
#This view should return these columns from the Orders table: order_id, order_date, tax_amount, and ship_date.
#This view should return these columns from the Order_Items table: item_price, discount_amount, final_price (the discount amount subtracted from the item price), quantity, and item_total (the calculated total for the item).
#This view shou#ld return the product_name column from the Products table.
    CREATE OR REPLACE VIEW order_item_products
AS
SELECT o.order_id, order_date, tax_amount, ship_date, 
       product_name, item_price, discount_amount, item_price - discount_amount AS final_price, quantity, 
       (item_price - discount_amount) * quantity AS item_total       
FROM orders o
    JOIN order_items li ON o.order_id = li.order_id
    JOIN products p ON li.product_id = p.product_id;
