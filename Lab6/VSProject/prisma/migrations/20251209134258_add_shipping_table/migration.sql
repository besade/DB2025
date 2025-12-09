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
