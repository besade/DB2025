# **Sweet Shop - Database Design**
---
![ERD](/DB_ER_Diagram.jpg)
## Requirements
### **1. Stakeholder Needs**
- Customers need to register and manage their personal information (name, contact details, addresses).

- Customers want to browse products by category, add products to a cart, and place orders.

- Customers should be able to pay for their orders using different payment methods.

- Customers need to track the status of their orders.

- Customers should be able to leave reviews and ratings for purchased products.

- The business (store administrators) needs to manage product catalog, categories, and stock levels.

- The business must be able to record payments, transactions, and related financial data.

- The business needs analytical insights into sales, customer behavior, and product performance.

### **2. Data to be Stored**
- **Customer data**: first name, last name, phone number, email, date of birth.

- **Address data**: country, city, address line (linked to customer and order).

- **Category data**: category name for grouping products.

- **Cart data**: cart details linked to customers, including products and total price.

- **Order data**: order details, customer information, delivery type, status, order date, total price.

- **Order items**: products included in each order, with unit price, quantity, and total item price.

- **Payment data**: payment method, date, status, amount, transaction ID, linked to orders.

- **Review data**: product reviews written by customers, including comment, rating, and date.

### **3. Business Rules**
- Each customer can have multiple addresses.

- Each order is linked to one customer and one address.

- An order can contain multiple products (order items).

- A payment is associated with exactly one order.

- A product belongs to exactly one category.

- A product can appear in multiple orders and multiple carts.

- Each cart is linked to one customer and can contain multiple cart items.

- A customer can leave multiple reviews, but only one per product.

- Stock quantity must be updated whenever an order is placed.

- Total price of orders, cart items, and order items must be computed based on product prices and quantities.

- Payments must only be accepted for orders with valid status (e.g., pending or confirmed).

- Reviews can only be created by customers who have purchased the product.

## Entities, Atributes and Relationships

### **Entities and Attributes**

**Customer**
**PK**: customer_id
first_name
last_name
phone_number
email
date_of_birth

**Address**
**PK**: address_id
**FK**: customer_id
country
city
address_line

**Cart**
**PK**: cart_id
**FK**: customer_id
total_price

**Cart Item**
**PK**: cart_id
**PK**: product_id
unit_price
quantity
total_item_price

**Order**
**PK**: order_id
**FK**: customer_id
**FK**: address_id
recipient_first_name
recipient_last_name
customer_is_recipient
delivery_type
order_date
status
total_price

**Order Item**
**PK**: order_id
**PK**: product_id
unit_price
quantity
total_item_price

**Payment**
**PK**: payment_id
**FK**: order_id
payment_method
payment_date
status
amount
transaction_id

**Product**
**PK**: product_id
**FK**: category_id
name
country
weight
stock_quantity
price

**Category**
**PK**: category_id
name

**Review**
**PK**: review_id
**FK**: customer_id
**FK**: product_id
comment
rating
review_date

### **Relationships and Limitations**

- A Customer can have multiple Addresses.

- A Customer can create multiple Orders.

- Each Order is linked to one Customer and one Address.

- An Order can contain multiple Order Items (many-to-many between Orders and Products).

- Each Payment is linked to exactly one Order.

- A Customer has one Cart, which can contain multiple Cart Items (many-to-many between Cart and Products).

- Each Product belongs to one Category.

- A Customer can leave multiple Reviews, but only one per Product.

- Each Review references a Customer and a Product.