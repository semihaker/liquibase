--liquibase formatted sql

-- ========================================
-- TEST VERİTABANI - SADECE DML CHANGESET'LERİ
-- ========================================

--changeset admin:201:insert-test-customers-data context:dml
INSERT INTO test_customers (customer_code, first_name, last_name, email, phone, birth_date) VALUES
('CUST001', 'Ahmet', 'Yılmaz', 'ahmet.yilmaz@email.com', '+90 555 123 4567', '1985-03-15'),
('CUST002', 'Fatma', 'Demir', 'fatma.demir@email.com', '+90 555 234 5678', '1990-07-22'),
('CUST003', 'Mehmet', 'Kaya', 'mehmet.kaya@email.com', '+90 555 345 6789', '1982-11-08'),
('CUST004', 'Ayşe', 'Özkan', 'ayse.ozkan@email.com', '+90 555 456 7890', '1988-05-12'),
('CUST005', 'Ali', 'Çelik', 'ali.celik@email.com', '+90 555 567 8901', '1995-09-30');

--rollback DELETE FROM test_customers WHERE customer_code IN ('CUST001', 'CUST002', 'CUST003', 'CUST004', 'CUST005');

--changeset admin:202:insert-test-addresses-data context:dml
INSERT INTO test_addresses (customer_id, address_type, street_address, city, state, postal_code, country, is_default) VALUES
(1, 'both', 'Atatürk Caddesi No:123', 'İstanbul', 'İstanbul', '34000', 'Turkey', true),
(1, 'shipping', 'İstiklal Caddesi No:456', 'İstanbul', 'İstanbul', '34001', 'Turkey', false),
(2, 'both', 'Kızılay Meydanı No:789', 'Ankara', 'Ankara', '06000', 'Turkey', true),
(3, 'both', 'Alsancak Mahallesi No:321', 'İzmir', 'İzmir', '35000', 'Turkey', true),
(4, 'both', 'Konyaaltı Caddesi No:654', 'Antalya', 'Antalya', '07000', 'Turkey', true),
(5, 'both', 'Karşıyaka Mahallesi No:987', 'Bursa', 'Bursa', '16000', 'Turkey', true);

--rollback DELETE FROM test_addresses WHERE customer_id IN (1, 2, 3, 4, 5);

--changeset admin:203:insert-test-orders-data context:dml
INSERT INTO test_orders (order_number, customer_id, order_date, delivery_date, total_amount, tax_amount, discount_amount, final_amount, status, payment_method) VALUES
('ORD-2024-001', 1, '2024-01-15 10:30:00', '2024-01-18', 299.99, 29.99, 0, 329.98, 'delivered', 'credit_card'),
('ORD-2024-002', 2, '2024-01-16 14:20:00', '2024-01-19', 149.99, 14.99, 15.00, 149.98, 'shipped', 'bank_transfer'),
('ORD-2024-003', 3, '2024-01-17 09:15:00', '2024-01-20', 599.99, 59.99, 50.00, 609.98, 'processing', 'credit_card'),
('ORD-2024-004', 1, '2024-01-18 16:45:00', '2024-01-21', 89.99, 8.99, 0, 98.98, 'confirmed', 'cash'),
('ORD-2024-005', 4, '2024-01-19 11:30:00', '2024-01-22', 199.99, 19.99, 20.00, 199.98, 'pending', 'credit_card');

--rollback DELETE FROM test_orders WHERE order_number IN ('ORD-2024-001', 'ORD-2024-002', 'ORD-2024-003', 'ORD-2024-004', 'ORD-2024-005');

--changeset admin:204:insert-test-order-items-data context:dml
INSERT INTO test_order_items (order_id, product_id, quantity, unit_price, discount_percent, total_price) VALUES
(1, 1, 1, 299.99, 0, 299.99),
(2, 3, 1, 129.99, 10, 116.99),
(2, 4, 1, 29.99, 5, 28.49),
(3, 2, 1, 899.99, 5, 854.99),
(4, 5, 1, 49.99, 0, 49.99),
(4, 6, 1, 39.99, 0, 39.99),
(5, 1, 1, 199.99, 10, 179.99);

--rollback DELETE FROM test_order_items WHERE order_id IN (1, 2, 3, 4, 5);
