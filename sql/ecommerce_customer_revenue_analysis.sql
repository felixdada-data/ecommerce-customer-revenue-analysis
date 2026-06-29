USE ecommerce_analysis;
CREATE TABLE customers (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Region VARCHAR(20),
    State VARCHAR(50),
    Segment VARCHAR(30),
    Join_Date DATE
);

CREATE TABLE products (
    Product_ID VARCHAR(20) PRIMARY KEY,
    Product_Category VARCHAR(50),
    Product_Name VARCHAR(100),
    Unit_Price DECIMAL(10,2),
    Unit_Cost DECIMAL(10,2)
);

CREATE TABLE orders (
    Order_ID VARCHAR(20) PRIMARY KEY,
    Order_Date DATE,
    Customer_ID VARCHAR(20),
    Product_ID VARCHAR(20),
    Sales_Rep VARCHAR(50),
    Quantity INT,
    Discount_Rate DECIMAL(5,2),
    Payment_Status VARCHAR(20),
    Shipping_Cost DECIMAL(10,2),
    FOREIGN KEY (Customer_ID) REFERENCES customers(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES products(Product_ID)
);

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT 
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM orders) AS total_orders;
    
    SELECT COUNT(*) AS total_customers
FROM customers;

INSERT INTO customers (
    Customer_ID,
    Customer_Name,
    Region,
    State,
    Segment,
    Join_Date
)
SELECT
    Customer_ID,
    Customer_Name,
    Region,
    State,
    Segment,
    STR_TO_DATE(Join_Date, '%d/%m/%Y')
FROM customers_staging;

SELECT COUNT(*) AS total_customers
FROM customers;

INSERT INTO orders (
    Order_ID,
    Order_Date,
    Customer_ID,
    Product_ID,
    Sales_Rep,
    Quantity,
    Discount_Rate,
    Payment_Status,
    Shipping_Cost
)
SELECT
    Order_ID,
    STR_TO_DATE(Order_Date, '%Y-%m-%d'),
    Customer_ID,
    Product_ID,
    Sales_Rep,
    Quantity,
    Discount_Rate,
    TRIM(Payment_Status),
    Shipping_Cost
FROM orders_staging;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT
    o.Order_ID,
    o.Order_Date,
    c.Customer_Name,
    c.Region,
    c.Segment,
    p.Product_Name,
    p.Product_Category,
    o.Sales_Rep,
    o.Quantity,
    p.Unit_Price,
    o.Discount_Rate,
    o.Payment_Status,
    o.Shipping_Cost
FROM orders o
JOIN customers c
    ON o.Customer_ID = c.Customer_ID
JOIN products p
    ON o.Product_ID = p.Product_ID
LIMIT 10;

SELECT
    c.Region,
    p.Product_Name,
    o.Sales_Rep,
    o.Quantity,
    p.Unit_Price,
    o.Discount_Rate,
    o.Shipping_Cost,
    ROUND(o.Quantity * p.Unit_Price * (1 - o.Discount_Rate), 2) AS Revenue,
    ROUND(
        (o.Quantity * p.Unit_Price * (1 - o.Discount_Rate))
        - (o.Quantity * p.Unit_Cost)
        - o.Shipping_Cost,
        2
    ) AS Profit
FROM orders o
JOIN customers c
    ON o.Customer_ID = c.Customer_ID
JOIN products p
    ON o.Product_ID = p.Product_ID
LIMIT 10;

SELECT
    c.Region,
    ROUND(SUM(o.Quantity * p.Unit_Price * (1 - o.Discount_Rate)), 2) AS Total_Revenue,
    ROUND(
        SUM(
            (o.Quantity * p.Unit_Price * (1 - o.Discount_Rate))
            - (o.Quantity * p.Unit_Cost)
            - o.Shipping_Cost
        ),
        2
    ) AS Total_Profit
FROM orders o
JOIN customers c
    ON o.Customer_ID = c.Customer_ID
JOIN products p
    ON o.Product_ID = p.Product_ID
GROUP BY c.Region
ORDER BY Total_Revenue DESC;

SELECT
    p.Product_Name,
    p.Product_Category,
    ROUND(SUM(o.Quantity * p.Unit_Price * (1 - o.Discount_Rate)), 2) AS Total_Revenue,
    ROUND(
        SUM(
            (o.Quantity * p.Unit_Price * (1 - o.Discount_Rate))
            - (o.Quantity * p.Unit_Cost)
            - o.Shipping_Cost
        ),
        2
    ) AS Total_Profit
FROM orders o
JOIN products p
    ON o.Product_ID = p.Product_ID
GROUP BY
    p.Product_Name,
    p.Product_Category
ORDER BY Total_Revenue DESC;

SELECT
    o.Sales_Rep,
    ROUND(SUM(o.Quantity * p.Unit_Price * (1 - o.Discount_Rate)), 2) AS Total_Revenue,
    ROUND(
        SUM(
            (o.Quantity * p.Unit_Price * (1 - o.Discount_Rate))
            - (o.Quantity * p.Unit_Cost)
            - o.Shipping_Cost
        ),
        2
    ) AS Total_Profit
FROM orders o
JOIN products p
    ON o.Product_ID = p.Product_ID
GROUP BY o.Sales_Rep
ORDER BY Total_Revenue DESC;

SELECT
    c.Segment,
    ROUND(SUM(o.Quantity * p.Unit_Price * (1 - o.Discount_Rate)), 2) AS Total_Revenue,
    ROUND(
        SUM(
            (o.Quantity * p.Unit_Price * (1 - o.Discount_Rate))
            - (o.Quantity * p.Unit_Cost)
            - o.Shipping_Cost
        ),
        2
    ) AS Total_Profit
FROM orders o
JOIN customers c
    ON o.Customer_ID = c.Customer_ID
JOIN products p
    ON o.Product_ID = p.Product_ID
GROUP BY c.Segment
ORDER BY Total_Revenue DESC;

SELECT
    TRIM(o.Payment_Status) AS Payment_Status,
    ROUND(SUM(o.Quantity * p.Unit_Price * (1 - o.Discount_Rate)), 2) AS Total_Revenue,
    ROUND(
        SUM(
            (o.Quantity * p.Unit_Price * (1 - o.Discount_Rate))
            - (o.Quantity * p.Unit_Cost)
            - o.Shipping_Cost
        ),
        2
    ) AS Total_Profit
FROM orders o
JOIN products p
    ON o.Product_ID = p.Product_ID
GROUP BY TRIM(o.Payment_Status)
ORDER BY Total_Revenue DESC;

SELECT
    MONTHNAME(o.Order_Date) AS Month_Name,
    MONTH(o.Order_Date) AS Month_Number,
    ROUND(SUM(o.Quantity * p.Unit_Price * (1 - o.Discount_Rate)), 2) AS Total_Revenue,
    ROUND(
        SUM(
            (o.Quantity * p.Unit_Price * (1 - o.Discount_Rate))
            - (o.Quantity * p.Unit_Cost)
            - o.Shipping_Cost
        ),
        2
    ) AS Total_Profit
FROM orders o
JOIN products p
    ON o.Product_ID = p.Product_ID
GROUP BY
    MONTHNAME(o.Order_Date),
    MONTH(o.Order_Date)
ORDER BY Month_Number;

SELECT
    c.Customer_Name,
    c.Region,
    c.Segment,
    ROUND(SUM(o.Quantity * p.Unit_Price * (1 - o.Discount_Rate)), 2) AS Total_Revenue,
    ROUND(
        SUM(
            (o.Quantity * p.Unit_Price * (1 - o.Discount_Rate))
            - (o.Quantity * p.Unit_Cost)
            - o.Shipping_Cost
        ),
        2
    ) AS Total_Profit
FROM orders o
JOIN customers c
    ON o.Customer_ID = c.Customer_ID
JOIN products p
    ON o.Product_ID = p.Product_ID
GROUP BY
    c.Customer_Name,
    c.Region,
    c.Segment
ORDER BY Total_Revenue DESC
LIMIT 10;