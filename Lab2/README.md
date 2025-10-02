# Transforming ER Diagram into PostgreSQL Schema
![ERD](/BD_ER_Diagram2.jpg)

## **SQL Script**

### **Below is the full SQL script with CREATE TABLE and INSERT statements in the correct order. Comments are added for clarity:**

```sql
-- ==============================
-- ENUM Types
-- ==============================
CREATE TYPE payment_type AS ENUM ('card', 'paypal', 'apple_pay', 'google_pay');
CREATE TYPE status AS ENUM ('pending', 'success', 'failed', 'refunded');
CREATE TYPE delivery AS ENUM ('nova_poshta', 'ukr_poshta', 'meest');

-- ==============================
-- Customer Table
-- ==============================
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    phone_number VARCHAR(13) NOT NULL UNIQUE,
    email VARCHAR(60) NOT NULL UNIQUE,
    date_of_birth DATE NOT NULL CHECK(date_of_birth BETWEEN '1925-01-01' AND '2025-01-01')
);

-- ==============================
-- Address Table
-- ==============================
CREATE TABLE address (
    address_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    country VARCHAR(70) NOT NULL,
    city VARCHAR(200) NOT NULL,
    address_line VARCHAR(400) NOT NULL,
    address_is_default BOOL NOT NULL DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- ==============================
-- Category Table
-- ==============================
CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(30) NOT NULL
);

-- ==============================
-- Product Table
-- ==============================
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    product_country VARCHAR(70) NOT NULL,
    weight NUMERIC(5,3) NOT NULL CHECK (weight > 0),
    stock_quantity INTEGER NOT NULL,
    price NUMERIC(8,2) NOT NULL CHECK (price > 0),
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- ==============================
-- Cart Table
-- ==============================
CREATE TABLE cart (
    cart_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    total_price NUMERIC(8,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- ==============================
-- Cart Item Table
-- ==============================
CREATE TABLE cart_item (
    cart_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    PRIMARY KEY (cart_id, product_id),
    unit_price NUMERIC(8,2) NOT NULL CHECK(unit_price > 0),
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    total_item_price NUMERIC(9,2) GENERATED ALWAYS AS (unit_price * quantity) STORED,
    FOREIGN KEY (cart_id) REFERENCES cart(cart_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- ==============================
-- Order Table
-- ==============================
CREATE TABLE order_table (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    address_id INTEGER NOT NULL,
    recipient_first_name VARCHAR(25) NOT NULL,
    recipient_last_name VARCHAR(25) NOT NULL,
    customer_is_recipient BOOL NOT NULL DEFAULT FALSE,
    delivery_type delivery NOT NULL DEFAULT 'nova_poshta',
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    order_status status NOT NULL DEFAULT 'pending',
    total_price NUMERIC(9,2) NOT NULL CHECK(total_price > 0),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

-- ==============================
-- Order Item Table
-- ==============================
CREATE TABLE order_item (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    PRIMARY KEY (order_id, product_id),
    unit_price NUMERIC(8,2) NOT NULL CHECK (unit_price > 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    total_item_price NUMERIC(9,2) GENERATED ALWAYS AS (unit_price * quantity) STORED,
    FOREIGN KEY (order_id) REFERENCES order_table(order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- ==============================
-- Payment Table
-- ==============================
CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    payment_method payment_type NOT NULL,
    payment_date DATE NOT NULL,
    payment_status status NOT NULL,
    amount NUMERIC(9,2) NOT NULL CHECK (amount > 0),
    transaction_id VARCHAR(400) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES order_table(order_id)
);

-- ==============================
-- Review Table
-- ==============================
CREATE TABLE review (
    review_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    review_comment VARCHAR(350) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 10),
    review_date DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- ==============================
-- INSERT Statements (Data Population)
-- ==============================
-- Customers
INSERT INTO customer (first_name, last_name, phone_number, email, date_of_birth)
VALUES
('Ivan', 'Ivanov', '+380501234567', 'ivan@example.com', '1990-05-12'),
('Olena', 'Petrenko', '+380671234567', 'olena@example.com', '1985-08-30'),
('Andriy', 'Shevchenko', '+380931234567', 'andriy@example.com', '2000-01-15');

-- Addresses
INSERT INTO address (customer_id, country, city, address_line, address_is_default)
VALUES
(1, 'Ukraine', 'Kyiv', 'Khreshchatyk 1', TRUE),
(2, 'Ukraine', 'Lviv', 'Svobody Ave 10', TRUE),
(3, 'Ukraine', 'Odessa', 'Deribasivska 5', TRUE);

-- Categories
INSERT INTO category (category_name)
VALUES
('Chocolate'),
('Candy'),
('Cookies'),
('Gummies'),
('Cake & Pastry');

-- Products
INSERT INTO product (category_id, product_name, product_country, weight, stock_quantity, price)
VALUES
-- Chocolate
(1, 'Milk Chocolate Bar', 'Switzerland', 0.100, 200, 100.00),
(1, 'Dark Chocolate 70%', 'Belgium', 0.100, 150, 150.43),
(1, 'Chocolate Truffles', 'France', 0.050, 100, 400.00),

-- Candy
(2, 'Hard Candy Assortment', 'USA', 0.200, 300, 600.00),
(2, 'Lollipop', 'Ukraine', 0.050, 500, 50.00),
(2, 'Caramel Chews', 'Poland', 0.100, 250, 350.12),

-- Cookies
(3, 'Chocolate Chip Cookies', 'USA', 0.150, 200, 150.24),
(3, 'Oatmeal Cookies', 'UK', 0.120, 180, 270.00),
(3, 'Butter Cookies', 'Denmark', 0.100, 150, 300.00),

-- Gummies
(4, 'Gummy Bears', 'Germany', 0.100, 400, 120.12),
(4, 'Sour Worms', 'USA', 0.120, 350, 90.40),
(4, 'Fruit Gummies', 'Poland', 0.150, 300, 120.07),

-- Cake & Pastry
(5, 'Chocolate Cake Slice', 'Ukraine', 0.250, 50, 700.51),
(5, 'Croissant with Chocolate', 'France', 0.100, 80, 160.40),
(5, 'Cupcake with Frosting', 'USA', 0.120, 60, 400.12);

-- Carts
INSERT INTO cart (customer_id, total_price)
VALUES
(1, 0),
(2, 0),
(3, 0);

-- Cart Items
INSERT INTO cart_item (cart_id, product_id, unit_price, quantity)
VALUES
(1, 1, 140.05, 2),   -- Milk Chocolate Bar
(1, 7, 180.24, 3),   -- Chocolate Chip Cookies
(2, 4, 645.00, 1),   -- Hard Candy Assortment
(2, 13, 780.51, 1),  -- Chocolate Cake Slice
(3, 15, 440.12, 2),  -- Cupcake with Frosting
(3, 10, 120.40, 5);  -- Sour Worms

-- Orders
INSERT INTO order_table (customer_id, address_id, recipient_first_name, recipient_last_name, customer_is_recipient, delivery_type, order_status, total_price)
VALUES
(1, 1, 'Ivan', 'Ivanov', TRUE, 'nova_poshta', 'pending', 820.82),
(2, 2, 'Olena', 'Petrenko', TRUE, 'ukr_poshta', 'pending', 1425.51),
(3, 3, 'Andriy', 'Shevchenko', TRUE, 'meest', 'pending', 1482.24);

-- Order Items
INSERT INTO order_item (order_id, product_id, unit_price, quantity)
VALUES
(1, 1, 140.05, 2),
(1, 7, 180.24, 3),
(2, 4, 645.00, 1),
(2, 13, 780.51, 1),
(3, 15, 440.12, 2),
(3, 10, 120.40, 5);

-- Payments
INSERT INTO payment (order_id, payment_method, payment_date, payment_status, amount, transaction_id)
VALUES
(1, 'card', '2025-10-02', 'success', 820.82, 'TX2001'),
(2, 'paypal', '2025-10-02', 'pending', 1425.51, 'TX2002'),
(3, 'apple_pay', '2025-10-02', 'success', 1482.24, 'TX2003');

-- Reviews
INSERT INTO review (customer_id, product_id, review_comment, rating, review_date)
VALUES
(1, 1, 'Дуже смачний молочний шоколад, тане в роті!', 9, '2025-10-02'),
(1, 7, 'Печиво з шоколадними шматочками супер, куплю ще.', 8, '2025-10-02'),
(2, 4, 'Цукерки чудові, але трохи занадто солодкі для мене.', 7, '2025-10-01'),
(2, 13, 'Торт дуже красивий та смачний, порція велика.', 10, '2025-10-02'),
(3, 15, 'Капкейки смачні, крем хороший, але трохи сухуваті.', 8, '2025-10-01'),
(3, 10, 'Кислі черв’ячки сподобались, діти задоволені!', 9, '2025-10-02');
```

## **Schema Summary**

### **The database schema is designed to support an "Sweet Shop" with customers, products, orders, payments, and reviews.**
**Below is a summary of each table with its attributes, keys, and important constraints:**

### **1. customer**

customer_id (PK) – unique ID of the customer
first_name, last_name – personal data (required)
phone_number – must be unique
email – must be unique
date_of_birth – must be between 1925 and 2025

- Notes: Customers are the central entity in the system.

### **2. address**

address_id (PK) – unique ID of the address
customer_id (FK customer(customer_id))
country, city, address_line – full address details
address_is_default – marks default shipping address

- Notes: A customer can have multiple addresses.

### **3. category**

category_id (PK) – unique ID of category
category_name – category title (e.g., Chocolate, Candy)

### **4. product**

product_id (PK)
category_id (FK category(category_id))
product_name – name of the product
product_country – country of origin
weight – must be positive
stock_quantity – available stock
price – must be positive

- Notes: Each product belongs to one category.

### **5. cart**

cart_id (PK)
customer_id (FK → customer.customer_id)
total_price – default = 0

- Notes: Each customer has a shopping cart.

### **6. cart_item**

cart_id (FK cart(cart_id))
product_id (FK product(product_id))
unit_price – must be > 0
quantity – must be > 0
total_item_price – automatically calculated (unit_price * quantity)
Primary Key: (cart_id, product_id)

- Notes: A cart can contain multiple products, each with a quantity.

### **7. order_table**

order_id (PK)
customer_id (FK customer(customer_id))
address_id (FK address(address_id))
recipient_first_name, recipient_last_name
customer_is_recipient – boolean flag
delivery_type – enum (nova_poshta, ukr_poshta, meest)
order_date – defaults to current date
order_status – enum (pending, success, failed, refunded)
total_price – must be positive

- Notes: Represents a confirmed order placed by a customer.

### **8. order_item**
order_id (FK order_table(order_id))
product_id (FK product(product_id))
unit_price, quantity, total_item_price (generated column)
Primary Key: (order_id, product_id)

- Notes: Each order consists of multiple products.

### **9. payment**

payment_id (PK)
order_id (FK order_table(order_id))
payment_method – enum (card, paypal, apple_pay, google_pay)
payment_date – required
payment_status – enum (pending, success, failed, refunded)
amount – must be > 0
transaction_id – unique identifier of the transaction

- Notes: Every order must have at least one payment record.

### **10. review**
review_id (PK)
customer_id (FK customer(customer_id))
product_id (FK product(product_id))
review_comment – up to 350 chars
rating – between 1 and 10
review_date – defaults to current date

- Notes: Customers can leave reviews for products they purchased.

## **Proof of Data Population**

### **Each table has been populated with at least 3–5 records using INSERT statements.**

**Customer Table**
![Customer Table Screenshot](/customer_table.png)

**Product Table**
![Product Table Screenshot](/product_table.png)

**Order Table**
![Order Table Screenshot](/order_table.png)

**Review Table**
![Review Table Screenshot](/review_table.png)