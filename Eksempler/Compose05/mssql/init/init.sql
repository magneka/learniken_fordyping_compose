IF DB_ID('$(DBNAME)') IS NULL
    CREATE DATABASE [$(DBNAME)];
GO

USE [$(DBNAME)];
GO

IF OBJECT_ID('dbo.customer', 'U') IS NULL
BEGIN
    CREATE TABLE customer (
        id INT IDENTITY(1,1) PRIMARY KEY,
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        phone VARCHAR(20),
        city VARCHAR(50)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.customer)
BEGIN
    INSERT INTO customer (first_name, last_name, email, phone, city) VALUES
        ('Ola', 'Nordmann', 'ola.nordmann@example.com', '11111111', 'Oslo'),
        ('Kari', 'Hansen', 'kari.hansen@example.com', '22222222', 'Bergen'),
        ('Per', 'Olsen', 'per.olsen@example.com', '33333333', 'Trondheim'),
        ('Anne', 'Larsen', 'anne.larsen@example.com', '44444444', 'Stavanger'),
        ('Erik', 'Andersen', 'erik.andersen@example.com', '55555555', 'Kristiansand'),
        ('Ingrid', 'Johansen', 'ingrid.johansen@example.com', '66666666', 'Tromso'),
        ('Lars', 'Pedersen', 'lars.pedersen@example.com', '77777777', 'Drammen'),
        ('Silje', 'Kristiansen', 'silje.kristiansen@example.com', '88888888', 'Fredrikstad'),
        ('Magnus', 'Jensen', 'magnus.jensen@example.com', '99999999', 'Sandnes'),
        ('Nora', 'Karlsen', 'nora.karlsen@example.com', '10101010', 'Sarpsborg');
END
GO
