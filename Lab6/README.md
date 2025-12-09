# **Schema Migrations with Prisma**

## **Схема при першому виклику "npx prisma db pull"**
```
generator client {
  provider = "prisma-client"
  output   = "../generated/prisma"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model address {
  address_id         Int           @id @default(autoincrement())
  customer_id        Int
  country            String        @db.VarChar(70)
  city               String        @db.VarChar(200)
  address_line       String        @db.VarChar(400)
  address_is_default Boolean       @default(false)
  customer           customer      @relation(fields: [customer_id], references: [customer_id], onDelete: NoAction, onUpdate: NoAction)
  order_table        order_table[]
}

model cart {
  cart_id     Int         @id @default(autoincrement())
  customer_id Int
  customer    customer    @relation(fields: [customer_id], references: [customer_id], onDelete: NoAction, onUpdate: NoAction)
  cart_item   cart_item[]
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model cart_item {
  cart_id    Int
  product_id Int
  quantity   Int
  cart       cart    @relation(fields: [cart_id], references: [cart_id], onDelete: NoAction, onUpdate: NoAction)
  product    product @relation(fields: [product_id], references: [product_id], onDelete: NoAction, onUpdate: NoAction)

  @@id([cart_id, product_id])
}

model category {
  category_id   Int       @id @default(autoincrement())
  category_name String    @db.VarChar(30)
  product       product[]
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model customer {
  customer_id   Int           @id @default(autoincrement())
  first_name    String        @db.VarChar(25)
  last_name     String        @db.VarChar(25)
  phone_number  String        @unique @db.VarChar(13)
  email         String        @unique @db.VarChar(60)
  date_of_birth DateTime      @db.Date
  address       address[]
  cart          cart[]
  order_table   order_table[]
  review        review[]
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model order_item {
  order_id    Int
  product_id  Int
  unit_price  Decimal     @db.Decimal(8, 2)
  quantity    Int
  order_table order_table @relation(fields: [order_id], references: [order_id], onDelete: NoAction, onUpdate: NoAction)
  product     product     @relation(fields: [product_id], references: [product_id], onDelete: NoAction, onUpdate: NoAction)

  @@id([order_id, product_id])
}

model order_table {
  order_id              Int          @id @default(autoincrement())
  customer_id           Int
  address_id            Int
  recipient_first_name  String       @db.VarChar(25)
  recipient_last_name   String       @db.VarChar(25)
  customer_is_recipient Boolean      @default(false)
  delivery_type         delivery     @default(nova_poshta)
  order_date            DateTime     @default(dbgenerated("CURRENT_DATE")) @db.Date
  order_status          status       @default(pending)
  order_item            order_item[]
  address               address      @relation(fields: [address_id], references: [address_id], onDelete: NoAction, onUpdate: NoAction)
  customer              customer     @relation(fields: [customer_id], references: [customer_id], onDelete: NoAction, onUpdate: NoAction)
  payment               payment[]
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model payment {
  payment_id     Int          @id @default(autoincrement())
  order_id       Int
  payment_method payment_type
  payment_date   DateTime     @db.Date
  payment_status status
  amount         Decimal      @db.Decimal(9, 2)
  transaction_id String       @db.VarChar(400)
  order_table    order_table  @relation(fields: [order_id], references: [order_id], onDelete: NoAction, onUpdate: NoAction)
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model product {
  product_id      Int          @id @default(autoincrement())
  category_id     Int
  product_name    String       @db.VarChar(200)
  product_country String       @db.VarChar(70)
  weight          Decimal      @db.Decimal(5, 3)
  stock_quantity  Int
  price           Decimal      @db.Decimal(8, 2)
  cart_item       cart_item[]
  order_item      order_item[]
  category        category     @relation(fields: [category_id], references: [category_id], onDelete: NoAction, onUpdate: NoAction)
  review          review[]
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model review {
  review_id      Int      @id @default(autoincrement())
  customer_id    Int
  product_id     Int
  review_comment String   @db.VarChar(350)
  rating         Int
  review_date    DateTime @default(dbgenerated("CURRENT_DATE")) @db.Date
  customer       customer @relation(fields: [customer_id], references: [customer_id], onDelete: NoAction, onUpdate: NoAction)
  product        product  @relation(fields: [product_id], references: [product_id], onDelete: NoAction, onUpdate: NoAction)
}

enum delivery {
  nova_poshta
  ukr_poshta
  meest
}

enum payment_type {
  card
  paypal
  apple_pay
  google_pay
}

enum status {
  pending
  success
  failed
  refunded
}
```

**Далі було створено дві міграції, перша для додавання нової таблиці Shipping (доставка), та друга для зміни існуючих таблиць Order_table та Shipping, з додаванням зв'язку між ними.**

## **Зміст першої міграції**
```sql
-- CreateEnum
CREATE TYPE "delivery" AS ENUM ('nova_poshta', 'ukr_poshta', 'meest');

-- CreateEnum
CREATE TYPE "payment_type" AS ENUM ('card', 'paypal', 'apple_pay', 'google_pay');

-- CreateEnum
CREATE TYPE "status" AS ENUM ('pending', 'success', 'failed', 'refunded');

-- CreateTable
CREATE TABLE "address" (
    "address_id" SERIAL NOT NULL,
    "customer_id" INTEGER NOT NULL,
    "country" VARCHAR(70) NOT NULL,
    "city" VARCHAR(200) NOT NULL,
    "address_line" VARCHAR(400) NOT NULL,
    "address_is_default" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "address_pkey" PRIMARY KEY ("address_id")
);

-- CreateTable
CREATE TABLE "cart" (
    "cart_id" SERIAL NOT NULL,
    "customer_id" INTEGER NOT NULL,

    CONSTRAINT "cart_pkey" PRIMARY KEY ("cart_id")
);

-- CreateTable
CREATE TABLE "cart_item" (
    "cart_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,

    CONSTRAINT "cart_item_pkey" PRIMARY KEY ("cart_id","product_id")
);

-- CreateTable
CREATE TABLE "category" (
    "category_id" SERIAL NOT NULL,
    "category_name" VARCHAR(30) NOT NULL,

    CONSTRAINT "category_pkey" PRIMARY KEY ("category_id")
);

-- CreateTable
CREATE TABLE "customer" (
    "customer_id" SERIAL NOT NULL,
    "first_name" VARCHAR(25) NOT NULL,
    "last_name" VARCHAR(25) NOT NULL,
    "phone_number" VARCHAR(13) NOT NULL,
    "email" VARCHAR(60) NOT NULL,
    "date_of_birth" DATE NOT NULL,

    CONSTRAINT "customer_pkey" PRIMARY KEY ("customer_id")
);

-- CreateTable
CREATE TABLE "order_item" (
    "order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "unit_price" DECIMAL(8,2) NOT NULL,
    "quantity" INTEGER NOT NULL,

    CONSTRAINT "order_item_pkey" PRIMARY KEY ("order_id","product_id")
);

-- CreateTable
CREATE TABLE "order_table" (
    "order_id" SERIAL NOT NULL,
    "customer_id" INTEGER NOT NULL,
    "address_id" INTEGER NOT NULL,
    "recipient_first_name" VARCHAR(25) NOT NULL,
    "recipient_last_name" VARCHAR(25) NOT NULL,
    "customer_is_recipient" BOOLEAN NOT NULL DEFAULT false,
    "delivery_type" "delivery" NOT NULL DEFAULT 'nova_poshta',
    "order_date" DATE NOT NULL DEFAULT CURRENT_DATE,
    "order_status" "status" NOT NULL DEFAULT 'pending',

    CONSTRAINT "order_table_pkey" PRIMARY KEY ("order_id")
);

-- CreateTable
CREATE TABLE "payment" (
    "payment_id" SERIAL NOT NULL,
    "order_id" INTEGER NOT NULL,
    "payment_method" "payment_type" NOT NULL,
    "payment_date" DATE NOT NULL,
    "payment_status" "status" NOT NULL,
    "amount" DECIMAL(9,2) NOT NULL,
    "transaction_id" VARCHAR(400) NOT NULL,

    CONSTRAINT "payment_pkey" PRIMARY KEY ("payment_id")
);

-- CreateTable
CREATE TABLE "product" (
    "product_id" SERIAL NOT NULL,
    "category_id" INTEGER NOT NULL,
    "product_name" VARCHAR(200) NOT NULL,
    "product_country" VARCHAR(70) NOT NULL,
    "weight" DECIMAL(5,3) NOT NULL,
    "stock_quantity" INTEGER NOT NULL,
    "price" DECIMAL(8,2) NOT NULL,

    CONSTRAINT "product_pkey" PRIMARY KEY ("product_id")
);

-- CreateTable
CREATE TABLE "review" (
    "review_id" SERIAL NOT NULL,
    "customer_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "review_comment" VARCHAR(350) NOT NULL,
    "rating" INTEGER NOT NULL,
    "review_date" DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT "review_pkey" PRIMARY KEY ("review_id")
);

-- CreateTable
CREATE TABLE "Shipping" (
    "shipping_id" SERIAL NOT NULL,
    "tracking_code" VARCHAR(200),

    CONSTRAINT "Shipping_pkey" PRIMARY KEY ("shipping_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "customer_phone_number_key" ON "customer"("phone_number");

-- CreateIndex
CREATE UNIQUE INDEX "customer_email_key" ON "customer"("email");

-- AddForeignKey
ALTER TABLE "address" ADD CONSTRAINT "address_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("customer_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "cart" ADD CONSTRAINT "cart_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("customer_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "cart_item" ADD CONSTRAINT "cart_item_cart_id_fkey" FOREIGN KEY ("cart_id") REFERENCES "cart"("cart_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "cart_item" ADD CONSTRAINT "cart_item_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("product_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "order_item" ADD CONSTRAINT "order_item_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "order_table"("order_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "order_item" ADD CONSTRAINT "order_item_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("product_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "order_table" ADD CONSTRAINT "order_table_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "address"("address_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "order_table" ADD CONSTRAINT "order_table_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("customer_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "payment" ADD CONSTRAINT "payment_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "order_table"("order_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "category"("category_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("customer_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("product_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
```

**Дана міграція така велика, оскільки є першою у даному проекті, prisma створює всі таблиці. Також важливим моментом є те, що спочатку мені знадобилось використати команду "npx prisma migrate reset", щоб не було конфліктів з вже існуючими заповненими даними таблиць (попередні дані були видалені).**

## **Зміст другої міграції**
```sql
/*
  Warnings:

  - A unique constraint covering the columns `[order_id]` on the table `Shipping` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `order_id` to the `Shipping` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Shipping" ADD COLUMN     "order_id" INTEGER NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Shipping_order_id_key" ON "Shipping"("order_id");

-- AddForeignKey
ALTER TABLE "Shipping" ADD CONSTRAINT "Shipping_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "order_table"("order_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
```

## **Схема після обох міграцій**
```
generator client {
  provider = "prisma-client"
  output   = "../generated/prisma"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model address {
  address_id         Int           @id @default(autoincrement())
  customer_id        Int
  country            String        @db.VarChar(70)
  city               String        @db.VarChar(200)
  address_line       String        @db.VarChar(400)
  address_is_default Boolean       @default(false)
  customer           customer      @relation(fields: [customer_id], references: [customer_id], onDelete: NoAction, onUpdate: NoAction)
  order_table        order_table[]
}

model cart {
  cart_id     Int         @id @default(autoincrement())
  customer_id Int
  customer    customer    @relation(fields: [customer_id], references: [customer_id], onDelete: NoAction, onUpdate: NoAction)
  cart_item   cart_item[]
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model cart_item {
  cart_id    Int
  product_id Int
  quantity   Int
  cart       cart    @relation(fields: [cart_id], references: [cart_id], onDelete: NoAction, onUpdate: NoAction)
  product    product @relation(fields: [product_id], references: [product_id], onDelete: NoAction, onUpdate: NoAction)

  @@id([cart_id, product_id])
}

model category {
  category_id   Int       @id @default(autoincrement())
  category_name String    @db.VarChar(30)
  product       product[]
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model customer {
  customer_id   Int           @id @default(autoincrement())
  first_name    String        @db.VarChar(25)
  last_name     String        @db.VarChar(25)
  phone_number  String        @unique @db.VarChar(13)
  email         String        @unique @db.VarChar(60)
  date_of_birth DateTime      @db.Date
  address       address[]
  cart          cart[]
  order_table   order_table[]
  review        review[]
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model order_item {
  order_id    Int
  product_id  Int
  unit_price  Decimal     @db.Decimal(8, 2)
  quantity    Int
  order_table order_table @relation(fields: [order_id], references: [order_id], onDelete: NoAction, onUpdate: NoAction)
  product     product     @relation(fields: [product_id], references: [product_id], onDelete: NoAction, onUpdate: NoAction)

  @@id([order_id, product_id])
}

model order_table {
  order_id              Int          @id @default(autoincrement())
  customer_id           Int
  address_id            Int
  recipient_first_name  String       @db.VarChar(25)
  recipient_last_name   String       @db.VarChar(25)
  customer_is_recipient Boolean      @default(false)
  delivery_type         delivery     @default(nova_poshta)
  order_date            DateTime     @default(dbgenerated("CURRENT_DATE")) @db.Date
  order_status          status       @default(pending)
  shipping              Shipping?
  order_item            order_item[]
  address               address      @relation(fields: [address_id], references: [address_id], onDelete: NoAction, onUpdate: NoAction)
  customer              customer     @relation(fields: [customer_id], references: [customer_id], onDelete: NoAction, onUpdate: NoAction)
  payment               payment[]
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model payment {
  payment_id     Int          @id @default(autoincrement())
  order_id       Int
  payment_method payment_type
  payment_date   DateTime     @db.Date
  payment_status status
  amount         Decimal      @db.Decimal(9, 2)
  transaction_id String       @db.VarChar(400)
  order_table    order_table  @relation(fields: [order_id], references: [order_id], onDelete: NoAction, onUpdate: NoAction)
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model product {
  product_id      Int          @id @default(autoincrement())
  category_id     Int
  product_name    String       @db.VarChar(200)
  product_country String       @db.VarChar(70)
  weight          Decimal      @db.Decimal(5, 3)
  stock_quantity  Int
  price           Decimal      @db.Decimal(8, 2)
  cart_item       cart_item[]
  order_item      order_item[]
  category        category     @relation(fields: [category_id], references: [category_id], onDelete: NoAction, onUpdate: NoAction)
  review          review[]
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model review {
  review_id      Int      @id @default(autoincrement())
  customer_id    Int
  product_id     Int
  review_comment String   @db.VarChar(350)
  rating         Int
  review_date    DateTime @default(dbgenerated("CURRENT_DATE")) @db.Date
  customer       customer @relation(fields: [customer_id], references: [customer_id], onDelete: NoAction, onUpdate: NoAction)
  product        product  @relation(fields: [product_id], references: [product_id], onDelete: NoAction, onUpdate: NoAction)
}

model Shipping {
  shipping_id   Int         @id @default(autoincrement())
  tracking_code String?     @db.VarChar(200)
  order_id      Int         @unique
  order_table   order_table @relation(fields: [order_id], references: [order_id], onDelete: NoAction, onUpdate: NoAction)
}

enum delivery {
  nova_poshta
  ukr_poshta
  meest
}

enum payment_type {
  card
  paypal
  apple_pay
  google_pay
}

enum status {
  pending
  success
  failed
  refunded
}
```

# **Зображення заповнених даними таблиць у Prisma Studio**

![IMAGE](./images/1.png)

![IMAGE](./images/2.png)

![IMAGE](./images/3.png)

![IMAGE](./images/4.png)

![IMAGE](./images/5.png)

![IMAGE](./images/6.png)

![IMAGE](./images/7.png)

![IMAGE](./images/8.png)

![IMAGE](./images/9.png)

![IMAGE](./images/10.png)

![IMAGE](./images/11.png)

**Отже, у цій лабораторній роботі мені довелося знайомитись з новою для мене ORM, а саме Prisma. Мені було цікаво розібратись у даній ORM, вона здалася мені дуже зручною та легкою у використанні.**