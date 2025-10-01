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