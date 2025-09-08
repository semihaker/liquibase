-- Liquibase formatted SQL
-- changeset system:seed-1 context:dml
USE testdb;
GO
MERGE app.users AS target
USING (SELECT 'admin' AS username, 'admin@example.com' AS email) AS src
ON target.username = src.username
WHEN NOT MATCHED BY TARGET THEN
  INSERT (username, email) VALUES (src.username, src.email);
GO

MERGE app.products AS target
USING (SELECT 'Sample' AS name, CAST(10.00 AS DECIMAL(18,2)) AS price) AS src
ON target.name = src.name
WHEN NOT MATCHED BY TARGET THEN
  INSERT (name, price) VALUES (src.name, src.price);
GO


