--liquibase formatted sql

--changeset admin:001:create-users-table context:ddl
CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME2 DEFAULT GETDATE()
);
--rollback DROP TABLE users;

--changeset admin:002:create-categories-table context:ddl
CREATE TABLE categories (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE()
);
--rollback DROP TABLE categories;

--changeset admin:003:create-products-table context:ddl
CREATE TABLE products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    price DECIMAL(10,2) NOT NULL,
    category_id INT,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);
--rollback DROP TABLE products;

--changeset admin:004:add-indexes context:ddl
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_users_email ON users(email);
--rollback DROP INDEX idx_products_category_id ON products; DROP INDEX idx_products_name ON products; DROP INDEX idx_users_email ON users;

--changeset admin:010:seed-categories context:dml
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Fashion and apparel'),
('Books', 'Books and literature'),
('Home & Garden', 'Home improvement and gardening supplies');
--rollback DELETE FROM categories WHERE name IN ('Electronics', 'Clothing', 'Books', 'Home & Garden');

--changeset admin:011:seed-products context:dml
INSERT INTO products (name, description, price, category_id) VALUES
('Laptop', 'High-performance laptop computer', 999.99, 1),
('Smartphone', 'Latest model smartphone', 699.99, 1),
('T-Shirt', 'Cotton t-shirt', 19.99, 2),
('Jeans', 'Blue denim jeans', 49.99, 2),
('Programming Book', 'Learn to code', 29.99, 3),
('Garden Tools', 'Complete garden tool set', 79.99, 4);
--rollback DELETE FROM products WHERE name IN ('Laptop', 'Smartphone', 'T-Shirt', 'Jeans', 'Programming Book', 'Garden Tools');

--changeset admin:012:seed-users context:dml
INSERT INTO users (username, email) VALUES
('admin', 'admin@example.com'),
('user1', 'user1@example.com'),
('user2', 'user2@example.com');
--rollback DELETE FROM users WHERE username IN ('admin', 'user1', 'user2');
