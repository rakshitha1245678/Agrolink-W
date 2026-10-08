CREATE TYPE user_role AS ENUM ('CUSTOMER','FARMER','ADMIN');
CREATE TYPE order_status AS ENUM ('PENDING_PAYMENT','CONFIRMED','PAYMENT_FAILED','CANCELLED');
CREATE TYPE payment_status AS ENUM ('PENDING','PAID','FAILED');

CREATE TABLE users (
 id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, email VARCHAR(255) UNIQUE NOT NULL,
 password_hash TEXT NOT NULL, role user_role NOT NULL DEFAULT 'CUSTOMER', active BOOLEAN NOT NULL DEFAULT true,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE products (
 id SERIAL PRIMARY KEY, farmer_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 name VARCHAR(160) NOT NULL, description TEXT NOT NULL DEFAULT '', category VARCHAR(80) NOT NULL,
 price NUMERIC(12,2) NOT NULL CHECK(price > 0), stock_quantity INTEGER NOT NULL CHECK(stock_quantity >= 0), image_url TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE orders (
 id SERIAL PRIMARY KEY, customer_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 total_amount NUMERIC(12,2) NOT NULL CHECK(total_amount >= 0), status order_status NOT NULL DEFAULT 'PENDING_PAYMENT',
 payment_status payment_status NOT NULL DEFAULT 'PENDING', created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE order_items (
 id SERIAL PRIMARY KEY, order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
 product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT, farmer_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 quantity INTEGER NOT NULL CHECK(quantity > 0), price NUMERIC(12,2) NOT NULL CHECK(price >= 0), subtotal NUMERIC(12,2) NOT NULL CHECK(subtotal >= 0));
CREATE TABLE payments (
 id SERIAL PRIMARY KEY, order_id INTEGER NOT NULL UNIQUE REFERENCES orders(id) ON DELETE CASCADE,
 razorpay_order_id VARCHAR(120), razorpay_payment_id VARCHAR(120), amount NUMERIC(12,2) NOT NULL,
 status payment_status NOT NULL DEFAULT 'PENDING', created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE INDEX idx_products_farmer ON products(farmer_id); CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_orders_customer ON orders(customer_id); CREATE INDEX idx_items_farmer ON order_items(farmer_id);
