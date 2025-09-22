--liquibase formatted sql

--changeset admin:020:create-orders-table context:ddl
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

--changeset admin:021:create-order-items-table context:ddl
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL
);
--rollback DROP TABLE order_items;

--changeset admin:022:add-constraints context:ddl
ALTER TABLE orders ADD CONSTRAINT chk_status CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled'));
ALTER TABLE order_items ADD CONSTRAINT chk_quantity CHECK (quantity > 0);
ALTER TABLE order_items ADD CONSTRAINT chk_unit_price CHECK (unit_price > 0);
--rollback ALTER TABLE orders DROP CONSTRAINT chk_status; ALTER TABLE order_items DROP CONSTRAINT chk_quantity; ALTER TABLE order_items DROP CONSTRAINT chk_unit_price;

--changeset admin:023:create-views context:ddl
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

--changeset admin:024:create-functions context:ddl
CREATE OR REPLACE FUNCTION update_order_total(order_id_param INTEGER)
RETURNS DECIMAL AS $$
DECLARE
    total DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(total_price), 0) INTO total
    FROM order_items
    WHERE order_id = order_id_param;
    
    UPDATE orders SET total_amount = total WHERE id = order_id_param;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;
--rollback DROP FUNCTION update_order_total(INTEGER);
