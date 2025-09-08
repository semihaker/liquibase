-- Liquibase formatted SQL
-- changeset system:schema context:ddl
IF DB_ID('testdb') IS NULL CREATE DATABASE testdb;
GO
USE testdb;
GO
CREATE SCHEMA app AUTHORIZATION dbo;
GO

-- changeset system:tables-1 context:ddl
CREATE TABLE app.users (
  id INT IDENTITY(1,1) PRIMARY KEY,
  username NVARCHAR(100) NOT NULL UNIQUE,
  email NVARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE app.products (
  id INT IDENTITY(1,1) PRIMARY KEY,
  name NVARCHAR(255) NOT NULL,
  price DECIMAL(18,2) NOT NULL,
  created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO


