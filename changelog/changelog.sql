--liquibase formatted sql

--changeset semih:001:create-users-table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE users;

--changeset semih:002:create-products-table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE products;

--changeset semih:003:add-indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_name ON products(name);

--rollback DROP INDEX idx_users_email; DROP INDEX idx_products_name;



--changeset semih:004:add-categories-table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE categories;

--changeset semih:005:add-category-id-to-products
ALTER TABLE products ADD COLUMN category_id INTEGER REFERENCES categories(id);

--rollback ALTER TABLE products DROP COLUMN category_id;

--include advanced-migrations.sql
--include seed-data.sql
--include test-database.sql
