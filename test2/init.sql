-- Create the database if not exists
drop database if exists real_estate_database;
CREATE DATABASE real_estate_database;

-- Use the database
USE real_estate_database;

-- Create table employees
CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    position VARCHAR(255) NOT NULL
);

-- Create table salaryPayments
CREATE TABLE IF NOT EXISTS salaryPayments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    salaryAmount DECIMAL(10, 2),
    monthlyBonus DECIMAL(10, 2),
    yearOfPayment INT,
    monthOfPayment INT,
    dateOfPayment DATE,
    employee_id INT,
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- Create table actions
CREATE TABLE IF NOT EXISTS actions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    actionType VARCHAR(255) NOT NULL
);

-- Create table types
CREATE TABLE IF NOT EXISTS types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    typeName VARCHAR(255) NOT NULL
);

-- Create table customers
CREATE TABLE IF NOT EXISTS customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255),
    phone VARCHAR(20),
    name VARCHAR(255)
);

-- Create table properties
CREATE TABLE IF NOT EXISTS properties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    area DECIMAL(10, 2),
    price DECIMAL(10, 2),
    location VARCHAR(255),
    description TEXT,
    type_id INT,
    customer_id INT,
    FOREIGN KEY (type_id) REFERENCES types(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Create table ads
CREATE TABLE IF NOT EXISTS ads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    publicationDate DATE,
    isActual BOOLEAN,
    action_id INT,
    property_id INT,
    FOREIGN KEY (action_id) REFERENCES actions(id),
    FOREIGN KEY (property_id) REFERENCES properties(id)
);

-- Create table deals
CREATE TABLE IF NOT EXISTS deals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dealDate DATE,
    paymentType VARCHAR(255),
    employee_id INT,
    ad_id INT,
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (ad_id) REFERENCES ads(id)
);

-- Populate table types with limited types
INSERT INTO types (typeName) VALUES
('ground'),
('building and ground'),
('apartment'),
('house'),
('maisonette');

-- Populate table actions with limited actions
INSERT INTO actions (actionType) VALUES
('for sale'),
('buying'),
('for rent');

-- Sample data for employees
INSERT INTO employees (name, position) VALUES
('John Doe', 'Agent'),
('Jane Smith', 'Manager'),
('Mike Johnson', 'Assistant'),
('Emily Brown', 'Agent'),
('David Lee', 'Assistant'),
('Sarah Wilson', 'Manager'),
('Michael Thompson', 'Agent'),
('Jessica Martinez', 'Assistant'),
('Daniel Garcia', 'Manager'),
('Lisa Robinson', 'Agent');

-- Sample data for customers
INSERT INTO customers (email, phone, name) VALUES
('customer1@example.com', '123456789', 'Alice Johnson'),
('customer2@example.com', '987654321', 'Bob Smith'),
('customer3@example.com', '555555555', 'Charlie Davis'),
('customer4@example.com', '777777777', 'David Jones'),
('customer5@example.com', '111111111', 'Emma Taylor'),
('customer6@example.com', '999999999', 'Frank Wilson'),
('customer7@example.com', '222222222', 'Grace Martinez'),
('customer8@example.com', '888888888', 'Henry Anderson'),
('customer9@example.com', '666666666', 'Isabella Thomas'),
('customer10@example.com', '444444444', 'Jack White');

-- Sample data for properties
INSERT INTO properties (area, price, location, description, type_id, customer_id) VALUES
(150.5, 200000, 'Downtown', 'Spacious apartment with a great view', 3, 1),
(300, 500000, 'Suburb', 'Cozy house with a backyard', 4, 2),
(200, 300000, 'City Center', 'Ground for commercial use', 1, 3),
(400, 700000, 'Rural Area', 'Building and ground for sale', 2, 4),
(120, 150000, 'Suburb', 'Apartment with modern amenities', 3, 5),
(350, 600000, 'Downtown', 'Spacious house with a garden', 4, 6),
(180, 250000, 'City Center', 'Maisonette with rooftop terrace', 5, 7),
(250, 400000, 'Suburb', 'House with swimming pool', 4, 8),
(160, 220000, 'Rural Area', 'Ground for agricultural purposes', 1, 9),
(300, 450000, 'City Center', 'Building and ground suitable for development', 2, 10);

-- Sample data for ads
INSERT INTO ads (publicationDate, isActual, action_id, property_id) VALUES
('2024-04-01', true, 1, 1),
('2024-04-05', true, 1, 2),
('2024-04-08', true, 2, 3),
('2024-04-10', true, 2, 4),
('2024-04-12', true, 3, 5),
('2024-04-15', true, 3, 6),
('2024-04-18', true, 1, 7),
('2024-04-20', true, 1, 8),
('2024-04-22', true, 2, 9),
('2024-04-25', true, 2, 10);

-- Sample data for salaryPayments
INSERT INTO salaryPayments (salaryAmount, monthlyBonus, yearOfPayment, monthOfPayment, dateOfPayment, employee_id) VALUES
(3000, 500, 2024, 4, '2024-05-01', 1),
(2500, 400, 2024, 4, '2024-05-01', 2),
(2800, 450, 2024, 4, '2024-05-01', 3),
(3200, 550, 2024, 4, '2024-05-01', 4),
(2700, 420, 2024, 4, '2024-05-01', 5),
(3100, 480, 2024, 4, '2024-05-01', 6),
(2900, 470, 2024, 4, '2024-05-01', 7),
(2600, 430, 2024, 4, '2024-05-01', 8),
(3000, 500, 2024, 4, '2024-05-01', 9),
(2800, 450, 2024, 4, '2024-05-01', 10);

-- Sample data for deals
INSERT INTO deals (dealDate, paymentType, employee_id, ad_id) VALUES
('2024-04-10', 'Cash', 1, 1),
('2024-04-15', 'Mortgage', 2, 2),
('2024-04-20', 'Installments', 3, 3),
('2024-04-25', 'Cash', 4, 4),
('2024-04-30', 'Mortgage', 5, 5),
('2024-05-05', 'Cash', 6, 6),
('2024-05-10', 'Installments', 7, 7),
('2024-05-15', 'Mortgage', 8, 8),
('2024-05-20', 'Cash', 9, 9),
('2024-05-25', 'Mortgage', 10, 10);
