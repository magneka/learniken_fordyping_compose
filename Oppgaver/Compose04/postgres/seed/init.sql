CREATE TABLE IF NOT EXISTS customer (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(50)
);

INSERT INTO customer (first_name, last_name, email, phone, city) VALUES
('John', 'Smith', 'john.smith@example.com', '555-0101', 'New York'),
('Sarah', 'Johnson', 'sarah.johnson@example.com', '555-0102', 'Los Angeles'),
('Michael', 'Williams', 'michael.williams@example.com', '555-0103', 'Chicago'),
('Emily', 'Brown', 'emily.brown@example.com', '555-0104', 'Houston'),
('David', 'Jones', 'david.jones@example.com', '555-0105', 'Phoenix'),
('Jennifer', 'Garcia', 'jennifer.garcia@example.com', '555-0106', 'Philadelphia'),
('Robert', 'Miller', 'robert.miller@example.com', '555-0107', 'San Antonio'),
('Lisa', 'Davis', 'lisa.davis@example.com', '555-0108', 'San Diego'),
('William', 'Rodriguez', 'william.rodriguez@example.com', '555-0109', 'Dallas'),
('Patricia', 'Martinez', 'patricia.martinez@example.com', '555-0110', 'San Jose');