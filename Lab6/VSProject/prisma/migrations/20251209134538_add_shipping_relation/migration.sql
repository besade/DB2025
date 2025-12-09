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
