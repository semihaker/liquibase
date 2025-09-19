--liquibase formatted sql

--changeset admin:100:initial-system-data context:dml
INSERT INTO users (username, email) VALUES
('system', 'system@company.com'),
('admin', 'admin@company.com'),
('user1', 'user1@company.com'),
('user2', 'user2@company.com'),
('testuser', 'test@company.com');
--rollback DELETE FROM users WHERE username IN ('system', 'admin', 'user1', 'user2', 'testuser');

--changeset admin:101:initial-categories-data context:dml
INSERT INTO categories (name, description) VALUES
('System', 'System related items'),
('Administration', 'Administrative tools'),
('Development', 'Development tools and resources'),
('Testing', 'Testing and quality assurance'),
('Production', 'Production environment items');
--rollback DELETE FROM categories WHERE name IN ('System', 'Administration', 'Development', 'Testing', 'Production');

--changeset admin:102:initial-products-data context:dml
INSERT INTO products (name, description, price, category_id) VALUES
('System Monitor', 'System monitoring tool', 0.00, 1),
('Admin Panel', 'Administrative control panel', 0.00, 2),
('Code Editor', 'Advanced code editing software', 199.99, 3),
('Test Framework', 'Automated testing framework', 99.99, 4),
('Production Server', 'High-performance production server', 9999.99, 5);
--rollback DELETE FROM products WHERE name IN ('System Monitor', 'Admin Panel', 'Code Editor', 'Test Framework', 'Production Server');
