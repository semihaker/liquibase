--liquibase formatted sql

-- ========================================
-- TEST VERİTABANI - DDL CHANGESET'LERİ
-- ========================================

--changeset admin:101:create-test-customers-table context:ddl
CREATE TABLE test_customers (
    id SERIAL PRIMARY KEY,
    customer_code VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    birth_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE test_customers;

--changeset admin:102:create-test-orders-table context:ddl
CREATE TABLE test_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INTEGER NOT NULL REFERENCES test_customers(id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_date DATE,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    final_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    payment_method VARCHAR(30),
    shipping_address TEXT,
    billing_address TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE test_orders;

--changeset admin:103:create-test-order-items-table context:ddl
CREATE TABLE test_order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES test_orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    discount_percent DECIMAL(5,2) DEFAULT 0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
    total_price DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE test_order_items;

--changeset admin:104:create-test-addresses-table context:ddl
CREATE TABLE test_addresses (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES test_customers(id) ON DELETE CASCADE,
    address_type VARCHAR(20) NOT NULL CHECK (address_type IN ('billing', 'shipping', 'both')),
    street_address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Turkey',
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE test_addresses;

-- ========================================
-- İNDEKS VE KISITLAMALAR
-- ========================================

--changeset admin:105:add-test-indexes context:ddl
CREATE INDEX idx_test_customers_email ON test_customers(email);
CREATE INDEX idx_test_customers_customer_code ON test_customers(customer_code);
CREATE INDEX idx_test_orders_customer_id ON test_orders(customer_id);
CREATE INDEX idx_test_orders_order_date ON test_orders(order_date);
CREATE INDEX idx_test_orders_status ON test_orders(status);
CREATE INDEX idx_test_order_items_order_id ON test_order_items(order_id);
CREATE INDEX idx_test_order_items_product_id ON test_order_items(product_id);
CREATE INDEX idx_test_addresses_customer_id ON test_addresses(customer_id);

--rollback DROP INDEX idx_test_customers_email;
--rollback DROP INDEX idx_test_customers_customer_code;
--rollback DROP INDEX idx_test_orders_customer_id;
--rollback DROP INDEX idx_test_orders_order_date;
--rollback DROP INDEX idx_test_orders_status;
--rollback DROP INDEX idx_test_order_items_order_id;
--rollback DROP INDEX idx_test_order_items_product_id;
--rollback DROP INDEX idx_test_addresses_customer_id;

--changeset admin:106:add-test-constraints context:ddl
ALTER TABLE test_orders ADD CONSTRAINT chk_test_order_status 
CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'returned'));

ALTER TABLE test_orders ADD CONSTRAINT chk_test_order_amounts 
CHECK (total_amount >= 0 AND tax_amount >= 0 AND discount_amount >= 0 AND final_amount >= 0);

ALTER TABLE test_customers ADD CONSTRAINT chk_test_customer_birth_date 
CHECK (birth_date <= CURRENT_DATE);

--rollback ALTER TABLE test_orders DROP CONSTRAINT chk_test_order_status;
--rollback ALTER TABLE test_orders DROP CONSTRAINT chk_test_order_amounts;
--rollback ALTER TABLE test_customers DROP CONSTRAINT chk_test_customer_birth_date;

-- ========================================
-- VIEW'LAR
-- ========================================

--changeset admin:107:create-test-views context:ddl
CREATE VIEW test_customer_summary AS
SELECT 
    c.id,
    c.customer_code,
    c.first_name || ' ' || c.last_name as full_name,
    c.email,
    c.phone,
    c.is_active,
    COUNT(o.id) as total_orders,
    COALESCE(SUM(o.final_amount), 0) as total_spent,
    MAX(o.order_date) as last_order_date
FROM test_customers c
LEFT JOIN test_orders o ON c.id = o.customer_id
GROUP BY c.id, c.customer_code, c.first_name, c.last_name, c.email, c.phone, c.is_active;

--rollback DROP VIEW test_customer_summary;

CREATE VIEW test_order_summary AS
SELECT 
    o.id as order_id,
    o.order_number,
    c.customer_code,
    c.first_name || ' ' || c.last_name as customer_name,
    o.order_date,
    o.status,
    o.total_amount,
    o.final_amount,
    COUNT(oi.id) as item_count
FROM test_orders o
JOIN test_customers c ON o.customer_id = c.id
LEFT JOIN test_order_items oi ON o.id = oi.order_id
GROUP BY o.id, o.order_number, c.customer_code, c.first_name, c.last_name, o.order_date, o.status, o.total_amount, o.final_amount;

--rollback DROP VIEW test_order_summary;

-- ========================================
-- FONKSİYONLAR
-- ========================================

--changeset admin:108:create-test-functions context:ddl
CREATE OR REPLACE FUNCTION test_calculate_order_total(order_id_param INTEGER)
RETURNS DECIMAL AS $$
DECLARE
    total DECIMAL(12,2);
BEGIN
    SELECT COALESCE(SUM(total_price), 0) INTO total
    FROM test_order_items
    WHERE order_id = order_id_param;
    
    UPDATE test_orders SET total_amount = total WHERE id = order_id_param;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;

--rollback DROP FUNCTION test_calculate_order_total(INTEGER);

CREATE OR REPLACE FUNCTION test_get_customer_orders(customer_id_param INTEGER)
RETURNS TABLE (
    order_id INTEGER,
    order_number VARCHAR(30),
    order_date TIMESTAMP,
    status VARCHAR(20),
    total_amount DECIMAL(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT o.id, o.order_number, o.order_date, o.status, o.total_amount
    FROM test_orders o
    WHERE o.customer_id = customer_id_param
    ORDER BY o.order_date DESC;
END;
$$ LANGUAGE plpgsql;

--rollback DROP FUNCTION test_get_customer_orders(INTEGER);

-- ========================================
-- TEST VERİTABANI - DML CHANGESET'LERİ
-- ========================================

--changeset admin:109:insert-test-customers context:dml
INSERT INTO test_customers (customer_code, first_name, last_name, email, phone, birth_date) VALUES
('CUST001', 'Ahmet', 'Yılmaz', 'ahmet.yilmaz@email.com', '+90 555 123 4567', '1985-03-15'),
('CUST002', 'Fatma', 'Demir', 'fatma.demir@email.com', '+90 555 234 5678', '1990-07-22'),
('CUST003', 'Mehmet', 'Kaya', 'mehmet.kaya@email.com', '+90 555 345 6789', '1982-11-08'),
('CUST004', 'Ayşe', 'Özkan', 'ayse.ozkan@email.com', '+90 555 456 7890', '1988-05-12'),
('CUST005', 'Ali', 'Çelik', 'ali.celik@email.com', '+90 555 567 8901', '1995-09-30');

--rollback DELETE FROM test_customers WHERE customer_code IN ('CUST001', 'CUST002', 'CUST003', 'CUST004', 'CUST005');

--changeset admin:110:insert-test-addresses context:dml
INSERT INTO test_addresses (customer_id, address_type, street_address, city, state, postal_code, country, is_default) VALUES
(1, 'both', 'Atatürk Caddesi No:123', 'İstanbul', 'İstanbul', '34000', 'Turkey', true),
(1, 'shipping', 'İstiklal Caddesi No:456', 'İstanbul', 'İstanbul', '34001', 'Turkey', false),
(2, 'both', 'Kızılay Meydanı No:789', 'Ankara', 'Ankara', '06000', 'Turkey', true),
(3, 'both', 'Alsancak Mahallesi No:321', 'İzmir', 'İzmir', '35000', 'Turkey', true),
(4, 'both', 'Konyaaltı Caddesi No:654', 'Antalya', 'Antalya', '07000', 'Turkey', true),
(5, 'both', 'Karşıyaka Mahallesi No:987', 'Bursa', 'Bursa', '16000', 'Turkey', true);

--rollback DELETE FROM test_addresses WHERE customer_id IN (1, 2, 3, 4, 5);

--changeset admin:111:insert-test-orders context:dml
INSERT INTO test_orders (order_number, customer_id, order_date, delivery_date, total_amount, tax_amount, discount_amount, final_amount, status, payment_method) VALUES
('ORD-2024-001', 1, '2024-01-15 10:30:00', '2024-01-18', 299.99, 29.99, 0, 329.98, 'delivered', 'credit_card'),
('ORD-2024-002', 2, '2024-01-16 14:20:00', '2024-01-19', 149.99, 14.99, 15.00, 149.98, 'shipped', 'bank_transfer'),
('ORD-2024-003', 3, '2024-01-17 09:15:00', '2024-01-20', 599.99, 59.99, 50.00, 609.98, 'processing', 'credit_card'),
('ORD-2024-004', 1, '2024-01-18 16:45:00', '2024-01-21', 89.99, 8.99, 0, 98.98, 'confirmed', 'cash'),
('ORD-2024-005', 4, '2024-01-19 11:30:00', '2024-01-22', 199.99, 19.99, 20.00, 199.98, 'pending', 'credit_card');

--rollback DELETE FROM test_orders WHERE order_number IN ('ORD-2024-001', 'ORD-2024-002', 'ORD-2024-003', 'ORD-2024-004', 'ORD-2024-005');

--changeset admin:112:insert-test-order-items context:dml
INSERT INTO test_order_items (order_id, product_id, quantity, unit_price, discount_percent, total_price) VALUES
(1, 1, 1, 299.99, 0, 299.99),
(2, 3, 1, 129.99, 10, 116.99),
(2, 4, 1, 29.99, 5, 28.49),
(3, 2, 1, 899.99, 5, 854.99),
(4, 5, 1, 49.99, 0, 49.99),
(4, 6, 1, 39.99, 0, 39.99),
(5, 1, 1, 199.99, 10, 179.99);

--rollback DELETE FROM test_order_items WHERE order_id IN (1, 2, 3, 4, 5);

-- ========================================
-- TRIGGER'LAR
-- ========================================

--changeset admin:113:create-test-triggers context:ddl
CREATE OR REPLACE FUNCTION test_update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--rollback DROP FUNCTION test_update_updated_at();

CREATE TRIGGER test_trigger_update_customers_updated_at
    BEFORE UPDATE ON test_customers
    FOR EACH ROW
    EXECUTE FUNCTION test_update_updated_at();

CREATE TRIGGER test_trigger_update_orders_updated_at
    BEFORE UPDATE ON test_orders
    FOR EACH ROW
    EXECUTE FUNCTION test_update_updated_at();

--rollback DROP TRIGGER test_trigger_update_customers_updated_at ON test_customers;
--rollback DROP TRIGGER test_trigger_update_orders_updated_at ON test_orders;
