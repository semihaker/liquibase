--liquibase formatted sql

--changeset ozan:001:create-users-table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE users;

--changeset ozan:002:create-products-table
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

--changeset ozan:003:add-indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_name ON products(name);

--rollback DROP INDEX idx_users_email; DROP INDEX idx_products_name;

--changeset ozan:004:add-categories-table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE categories;

--changeset ozan:005:add-category-id-to-products
ALTER TABLE products ADD COLUMN category_id INTEGER REFERENCES categories(id);

--rollback ALTER TABLE products DROP COLUMN category_id;

--changeset ozan:006:create-orders-table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    shipping_address TEXT,
    billing_address TEXT
);

--rollback DROP TABLE orders;

--changeset ozan:007:create-order-items-table
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL
);

--rollback DROP TABLE order_items;

--changeset ozan:008:add-constraints
ALTER TABLE orders ADD CONSTRAINT chk_status CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled'));
ALTER TABLE order_items ADD CONSTRAINT chk_quantity CHECK (quantity > 0);
ALTER TABLE order_items ADD CONSTRAINT chk_unit_price CHECK (unit_price > 0);

--rollback ALTER TABLE orders DROP CONSTRAINT chk_status;
--rollback ALTER TABLE order_items DROP CONSTRAINT chk_quantity;
--rollback ALTER TABLE order_items DROP CONSTRAINT chk_unit_price;

--changeset ozan:009:create-views
CREATE VIEW order_summary AS
SELECT 
    o.id as order_id,
    u.username,
    o.order_date,
    o.total_amount,
    o.status,
    COUNT(oi.id) as item_count
FROM orders o
JOIN users u ON o.user_id = u.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, u.username, o.order_date, o.total_amount, o.status;

--rollback DROP VIEW order_summary;

--changeset ozan:010:add-comments
-- Tablo yorumları ekliyoruz
COMMENT ON TABLE users IS 'Kullanıcı bilgileri';
COMMENT ON TABLE products IS 'Ürün bilgileri';
COMMENT ON TABLE categories IS 'Kategori bilgileri';
COMMENT ON TABLE orders IS 'Sipariş bilgileri';
COMMENT ON TABLE order_items IS 'Sipariş detayları';

--rollback COMMENT ON TABLE users IS NULL;
--rollback COMMENT ON TABLE products IS NULL;
--rollback COMMENT ON TABLE categories IS NULL;
--rollback COMMENT ON TABLE orders IS NULL;
--rollback COMMENT ON TABLE order_items IS NULL;

--changeset ozan:011:insert-sample-categories
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Books and publications'),
('Home & Garden', 'Home improvement and garden supplies');

--rollback DELETE FROM categories WHERE name IN ('Electronics', 'Clothing', 'Books', 'Home & Garden');

--changeset ozan:012:insert-sample-products
INSERT INTO products (name, description, price, stock_quantity, category_id) VALUES
('iPhone 15', 'Latest Apple smartphone', 999.99, 50, 1),
('Samsung Galaxy S24', 'Android flagship phone', 899.99, 45, 1),
('Nike Air Max', 'Comfortable running shoes', 129.99, 100, 2),
('Adidas T-Shirt', 'Cotton sports t-shirt', 29.99, 200, 2),
('Clean Code Book', 'Software development best practices', 49.99, 75, 3),
('Garden Hose', '50ft flexible garden hose', 39.99, 30, 4);

--rollback DELETE FROM products WHERE name IN ('iPhone 15', 'Samsung Galaxy S24', 'Nike Air Max', 'Adidas T-Shirt', 'Clean Code Book', 'Garden Hose');

--changeset ozan:013:insert-sample-users
INSERT INTO users (username, email) VALUES
('john_doe', 'john@example.com'),
('jane_smith', 'jane@example.com'),
('admin_user', 'admin@example.com'),
('test_user', 'test@example.com');

--rollback DELETE FROM users WHERE username IN ('john_doe', 'jane_smith', 'admin_user', 'test_user');
