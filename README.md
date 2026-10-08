# AgroLink – Farmer to Consumer Marketplace

AgroLink is a medium-sized Express/PostgreSQL marketplace with a Tailwind + vanilla JavaScript frontend. Customers buy directly from farmers; admins monitor the platform.

## Features

- JWT authentication using HTTP-only cookies, bcrypt password hashes, and server-enforced CUSTOMER/FARMER/ADMIN RBAC.
- Public search/category product catalogue, farmer-owned product CRUD, cart stored locally, server-authoritative checkout, transactional stock locking, order visibility by role, and admin monitoring.
- Razorpay test order creation and HMAC verification when credentials are configured. Without credentials, a visible mock success/failure simulator preserves the exact payment-state flow.

## Setup

1. Create PostgreSQL database: `createdb agrolink`.
2. Import the schema: `psql -d agrolink -f database/schema.sql`.
3. Copy `backend/.env.example` to `backend/.env`, set `DATABASE_URL` and a long `JWT_SECRET`.
4. Install and run: `npm install`, then `npm run dev`.
5. Serve the workspace with VS Code Live Server (port 5500), then visit `http://localhost:5500/frontend/index.html`.

To create an admin, register a normal account then run `UPDATE users SET role='ADMIN' WHERE email='your@email';` in PostgreSQL.

## API overview

`/api/auth` handles register, login, logout, me. `/api/products` offers public reads and farmer/admin writes. `/api/orders/checkout` and `/api/orders/:id/payment` are customer-only. `/api/farmer/orders` is farmer-only. `/api/admin/*` is admin-only. All JSON API errors use appropriate 4xx/5xx statuses; a customer posting to `/api/products` receives 403.

## Testing

Register a farmer and customer. Log in as the farmer to add a product. Log in as the customer, search/filter it, add it to cart, and checkout. Select OK/Cancel in the mock confirmation to test PAID/FAILED behavior. Verify the farmer sees related order status. Promote a user to ADMIN using the SQL above to test platform views. Use browser devtools or Postman with the login Bearer token to confirm cross-role requests return 403.

## Architecture

Express routes call small controllers, PostgreSQL is accessed through a pool with parameterized queries, and checkout/payment verification uses transactions and row locks. The frontend only improves usability; authorization and price/stock calculations always happen in the API.

## Razorpay

Set `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` in `backend/.env` with test credentials. Checkout then creates an actual Razorpay order. A production UI can call Razorpay Checkout and POST its `razorpay_payment_id` plus `razorpay_signature` to the payment endpoint; the server validates the signature before marking paid. The included frontend intentionally defaults to its safe mock workflow for local credential-free testing.
