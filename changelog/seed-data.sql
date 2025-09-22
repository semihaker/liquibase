--liquibase formatted sql

--changeset admin:030:insert-sample-categories context:dml
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Books and publications'),
('Home & Garden', 'Home improvement and garden supplies');
--rollback DELETE FROM categories WHERE name IN ('Electronics', 'Clothing', 'Books', 'Home & Garden');

--changeset admin:031:insert-sample-products context:dml
INSERT INTO products (name, description, price, stock_quantity, category_id) VALUES
('iPhone 15', 'Latest Apple smartphone', 999.99, 50, 1),
('Samsung Galaxy S24', 'Android flagship phone', 899.99, 45, 1),
('Nike Air Max', 'Comfortable running shoes', 129.99, 100, 2),
('Adidas T-Shirt', 'Cotton sports t-shirt', 29.99, 200, 2),
('Clean Code Book', 'Software development best practices', 49.99, 75, 3),
('Garden Hose', '50ft flexible garden hose', 39.99, 30, 4);
--rollback DELETE FROM products WHERE name IN ('iPhone 15', 'Samsung Galaxy S24', 'Nike Air Max', 'Adidas T-Shirt', 'Clean Code Book', 'Garden Hose');

--changeset admin:032:insert-sample-users context:dml
INSERT INTO users (username, email) VALUES
('john_doe', 'john@example.com'),
('jane_smith', 'jane@example.com'),
('admin_user', 'admin@example.com'),
('test_user', 'test@example.com');
--rollback DELETE FROM users WHERE username IN ('john_doe', 'jane_smith', 'admin_user', 'test_user');
