--liquibase formatted sql

--changeset demo:001:create-users-table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
--rollback DROP TABLE IF EXISTS users;

--changeset demo:002:create-categories-table
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
--rollback DROP TABLE IF EXISTS categories;

--changeset demo:003:create-products-table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    category_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_category_id FOREIGN KEY (category_id) REFERENCES categories(id)
);
--rollback DROP TABLE IF EXISTS products;

--changeset demo:004:add-indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_name ON products(name);
--rollback DROP INDEX idx_users_email ON users; DROP INDEX idx_products_name ON products;

--changeset demo:010:seed-categories
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Books and publications');
--rollback DELETE FROM categories WHERE name IN ('Electronics','Clothing','Books');

--changeset demo:011:seed-products
INSERT INTO products (name, description, price, stock_quantity, category_id) VALUES
('iPhone 15', 'Latest Apple smartphone', 999.99, 50, 1),
('Samsung Galaxy S24', 'Android flagship phone', 899.99, 45, 1),
('Nike Air Max', 'Running shoes', 129.99, 100, 2),
('Clean Code Book', 'Software development best practices', 49.99, 75, 3);
--rollback DELETE FROM products WHERE name IN ('iPhone 15','Samsung Galaxy S24','Nike Air Max','Clean Code Book');

--changeset demo:012:seed-users
INSERT INTO users (username, email) VALUES
('john_doe', 'john@example.com'),
('jane_smith', 'jane@example.com');
--rollback DELETE FROM users WHERE username IN ('john_doe','jane_smith');

--changeset semih:020:seed-test-data
INSERT INTO users (username, email) VALUES
('test_user1','u1@example.com'),
('test_user2','u2@example.com');

INSERT INTO products (name, description, price, stock_quantity) VALUES
('Test Product semih','sample', 9.99, 10),
('Test Product B','sample', 19.99, 5);
--rollback DELETE FROM users WHERE username IN ('test_user1','test_user2'); DELETE FROM products WHERE name IN ('Test Product A','Test Product B');