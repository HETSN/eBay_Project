CREATE SCHEMA IF NOT EXISTS eBay;

CREATE TABLE IF NOT EXISTS user_profile (
    email VARCHAR PRIMARY KEY,
    user_password VARCHAR NOT NULL,
    first_name VARCHAR NOT NULL,
    last_name VARCHAR NOT NULL
);

CREATE TABLE IF NOT EXISTS "user" (
    user_id CHAR(10) PRIMARY KEY,
    email VARCHAR NOT NULL REFERENCES user_profile(email)
);

CREATE TABLE IF NOT EXISTS bank_details (
    account_number CHAR(10) PRIMARY KEY CHECK (account_balance >= 0) DEFAULT 0.0,
    balance NUMERIC(15,2) NOT NULL CHECK (balance >= 0.00) DEFAULT 0.00
);

CREATE TABLE IF NOT EXISTS seller (
    user_id CHAR(10) UNIQUE REFERENCES "user"(user_id),
    account_number CHAR(10) NOT NULL REFERENCES bank_details(account_number) CHECK (account_balance >= 0.00) DEFAULT 0.00,
    item_sold INT NOT NULL CHECK (item_sold >= 0) DEFAULT 0,
    avg_rating NUMERIC(2, 1) NOT NULL CHECK (avg_rating >= 0.0) DEFAULT 0.0,
    PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS buyer (
    user_id CHAR(10) PRIMARY KEY REFERENCES "user"(user_id)
);

CREATE TABLE IF NOT EXISTS product (
    product_id CHAR(10) PRIMARY KEY,
    product_name VARCHAR NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0.00),
    available_units INT NOT NULL CHECK (available_units >= 1) DEFAULT 1,
    watching_number INT NOT NULL CHECK (watching_number >= 0) DEFAULT 0,
    description TEXT NOT NULL,
    avg_rating NUMERIC(2,1) NOT NULL CHECK (avg_rating >= 0.0) DEFAULT 0.0,
	product_seller_id CHAR(10) NOT NULL REFERENCES seller(user_id)
);

CREATE TABLE IF NOT EXISTS product_review (
    product_id CHAR(10) REFERENCES product(product_id),
    user_id CHAR(10) REFERENCES buyer(user_id),
    rating NUMERIC(2,1) NOT NULL CHECK (rating >= 0.0) DEFAULT 0.0,
    "comment" TEXT,
    PRIMARY KEY (product_id, user_id)
);

CREATE TABLE IF NOT EXISTS watches (
    product_id CHAR(10) REFERENCES product(product_id),
    user_id CHAR(10) REFERENCES buyer(user_id),
    PRIMARY KEY (product_id, user_id)
);

CREATE TABLE IF NOT EXISTS cart (
    user_id CHAR(10) PRIMARY KEY REFERENCES buyer(user_id)
);

CREATE TABLE IF NOT EXISTS "contains" (
    product_id CHAR(10) REFERENCES product(product_id),
    user_id CHAR(10) REFERENCES cart(user_id),
    PRIMARY KEY (product_id, user_id)
);

CREATE TABLE IF NOT EXISTS category (
    cat_name VARCHAR PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS sub_category (
    sub_cat_name VARCHAR PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS category_has_subcategory (
    cat_name VARCHAR REFERENCES category(cat_name),
    sub_cat_name VARCHAR REFERENCES sub_category(sub_cat_name),
    PRIMARY KEY (cat_name, sub_cat_name)
);

CREATE TABLE IF NOT EXISTS has_category (
    cat_name VARCHAR REFERENCES category(cat_name),
    product_id CHAR(10) REFERENCES product(product_id),
    PRIMARY KEY (cat_name, product_id)
);

CREATE TABLE IF NOT EXISTS has_subcategory (
    sub_cat_name VARCHAR REFERENCES sub_category(sub_cat_name),
    product_id CHAR(10) REFERENCES product(product_id),
    PRIMARY KEY (sub_cat_name, product_id)
);

CREATE TABLE IF NOT EXISTS payment (
    transaction_id CHAR(10) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS shipping_address (
    user_id CHAR(10) REFERENCES "user"(user_id),
    is_default BOOLEAN NOT NULL DEFAULT TRUE,
    street VARCHAR,
    apartment_name VARCHAR,
    city VARCHAR NOT NULL,
    pincode CHAR(6) NOT NULL,
    "state" VARCHAR NOT NULL,
    PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS "order" (
    order_id CHAR(10) PRIMARY KEY,
    transaction_id CHAR(10) NOT NULL REFERENCES payment(transaction_id),
    buyer_user_id CHAR(10) NOT NULL REFERENCES buyer(user_id),
    shipping_address_user_id CHAR(10) NOT NULL REFERENCES shipping_address(user_id),
    shipping_cost DECIMAL(10, 2) NOT NULL,
    order_date DATE NOT NULL,
    total_order_cost DECIMAL(10, 2) NOT NULL CHECK (total_order_cost > 0.0) DEFAULT 0.0
);

CREATE TABLE IF NOT EXISTS shipping_status (
    tracking_id CHAR(10) PRIMARY KEY,
    delivered_date DATE,
    delivery_status VARCHAR NOT NULL,
    est_delivery_date DATE NOT NULL,
    order_id CHAR(10) NOT NULL REFERENCES "order"(order_id)
);

CREATE TABLE IF NOT EXISTS has_order (
    order_id CHAR(10) REFERENCES "order"(order_id),
    product_id CHAR(10) REFERENCES product(product_id),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE IF NOT EXISTS inv_house(
    inv_house_name VARCHAR PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS shipper (
    shipper_id CHAR(10) PRIMARY KEY,
    shipper_name VARCHAR NOT NULL,
    inv_house_name VARCHAR REFERENCES inv_house(inv_house_name)
);

CREATE TABLE IF NOT EXISTS inv_phone(
    inv_house_phone_number CHAR(10),
    inv_house_name VARCHAR REFERENCES inv_house(inv_house_name),
    PRIMARY KEY(inv_house_phone_number, inv_house_name)
);

CREATE TABLE IF NOT EXISTS shipper_phone (
    shipper_id CHAR(10) REFERENCES shipper(shipper_id),
    shipper_phone CHAR(10) NOT NULL,
    PRIMARY KEY(shipper_id, shipper_phone)
);

CREATE TABLE IF NOT EXISTS delivers (
    order_id CHAR(10) REFERENCES "order"(order_id),
    shipper_id CHAR(10) REFERENCES shipper(shipper_id),
    PRIMARY KEY (order_id, shipper_id)
);

CREATE TABLE IF NOT EXISTS user_phone (
    user_id CHAR(10) REFERENCES "user"(user_id),
    phone_number CHAR(10) CHECK (order_shipping_address_pincode ~ '^[0-9]{10}$'),
    PRIMARY KEY (user_id, phone_number)
);

CREATE TABLE IF NOT EXISTS product_image (
    image_url VARCHAR,
    product_id CHAR(10) REFERENCES product(product_id),
    PRIMARY KEY(image_url, product_id)
);