SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(50)
);

INSERT INTO customer (first_name, last_name, email, phone, city) VALUES
('Ola', 'Nordmann', 'ola.nordmann@example.com', '11111111', 'Oslo'),
('Kari', 'Nordmann', 'kari.nordmann@example.com', '22222222', 'Bergen'),
('Per', 'Hansen', 'per.hansen@example.com', '33333333', 'Trondheim'),
('Anne', 'Johansen', 'anne.johansen@example.com', '44444444', 'Stavanger'),
('Lars', 'Olsen', 'lars.olsen@example.com', '55555555', 'Tromsø'),
('Ingrid', 'Larsen', 'ingrid.larsen@example.com', '66666666', 'Kristiansand'),
('Erik', 'Andersen', 'erik.andersen@example.com', '77777777', 'Drammen'),
('Marte', 'Pedersen', 'marte.pedersen@example.com', '88888888', 'Fredrikstad'),
('Jonas', 'Kristiansen', 'jonas.kristiansen@example.com', '99999999', 'Sandnes'),
('Emma', 'Jensen', 'emma.jensen@example.com', '10101010', 'Sarpsborg');
