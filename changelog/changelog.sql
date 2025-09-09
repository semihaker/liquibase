--liquibase formatted sql

--changeset semih:001:create-users-table context:ddl
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE users;

--changeset semih:002:create-products-table context:ddl
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

--changeset semih:003:add-indexes context:ddl
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_name ON products(name);

--rollback DROP INDEX idx_users_email; DROP INDEX idx_products_name;



--changeset semih:004:add-categories-table context:ddl
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE categories;

--changeset semih:005:add-category-id-to-products context:ddl
ALTER TABLE products ADD COLUMN category_id INTEGER REFERENCES categories(id);

--rollback ALTER TABLE products DROP COLUMN category_id;

--changeset semih:010:seed-categories context:dml
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Books and publications');

--rollback DELETE FROM categories WHERE name IN ('Electronics', 'Clothing', 'Books');

--changeset semih:011:seed-products context:dml
INSERT INTO products (name, description, price, stock_quantity, category_id) VALUES
('iPhone 15', 'Latest Apple smartphone', 999.99, 50, 1),
('Samsung Galaxy S24', 'Android flagship phone', 899.99, 45, 1),
('Nike Air Max', 'Running shoes', 129.99, 100, 2),
('Clean Code Book', 'Software development best practices', 49.99, 75, 3);

--rollback DELETE FROM products WHERE name IN ('iPhone 15', 'Samsung Galaxy S24', 'Nike Air Max', 'Clean Code Book');

--changeset semih:012:seed-users context:dml
INSERT INTO users (username, email) VALUES
('john_doe', 'john@example.com'),
('jane_smith', 'jane@example.com');

--rollback DELETE FROM users WHERE username IN ('john_doe', 'jane_smith');

--include advanced-migrations.sql
--include seed-data.sql
--include test-database.sql
