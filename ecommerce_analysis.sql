-- ===========================
-- 📦 DATABASE SETUP
-- ===========================
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- ===========================
-- 🧱 TABLE CREATION
-- ===========================

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ===========================
-- 📊 SAMPLE DATA
-- ===========================

INSERT INTO customers (customer_name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');

INSERT INTO products (product_name, price) VALUES
('Laptop', 800.00),
('Smartphone', 500.00),
('Tablet', 300.00);

INSERT INTO orders (customer_id, order_date) VALUES
(1, '2024-04-01'),
(2, '2024-04-02'),
(1, '2024-04-05');

INSERT INTO order_details (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 3, 1),
(3, 1, 1),
(3, 3, 1);

-- ===========================
-- 🧪 SQL QUERIES FOR ANALYSIS
-- ===========================

-- a. SELECT, WHERE, GROUP BY, ORDER BY

-- Total orders per customer
SELECT customer_name, COUNT(*) AS total_orders
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customer_name
ORDER BY total_orders DESC;

-- WHERE: Customers who ordered after April 1, 2024
SELECT o.order_id, c.customer_name, o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date > '2024-04-01'
ORDER BY o.order_date ASC;

-- b. INNER JOIN
SELECT o.order_id, c.customer_name, p.product_name
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_details od ON o.order_id = od.order_id
INNER JOIN products p ON od.product_id = p.product_id;

-- b. LEFT JOIN
SELECT c.customer_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- c. Subquery: Customers with more than average number of orders
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > (
    SELECT AVG(order_count)
    FROM (
        SELECT customer_id, COUNT(*) AS order_count
        FROM orders
        GROUP BY customer_id
    ) AS subquery
);

-- d. Aggregate Functions: Total and average quantity sold per product
SELECT p.product_name, SUM(od.quantity) AS total_sold, AVG(od.quantity) AS avg_quantity
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_name;

-- e. Create View: Customer summary with total orders
CREATE VIEW customer_summary AS
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- View output
SELECT * FROM customer_summary;

-- f. Index optimization
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_product_id ON order_details(product_id);
