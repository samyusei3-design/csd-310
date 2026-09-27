-- Group D - Bacchus Winery Case Study - Milestone 2
-- Team Members: Verdis Moorer and Samuel Guizar

DROP DATABASE IF EXISTS bacchus_winery;
CREATE DATABASE bacchus_winery;
USE bacchus_winery;

CREATE TABLE department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE employee (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    job_title VARCHAR(75) NOT NULL,
    email VARCHAR(100) UNIQUE,
    hire_date DATE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

CREATE TABLE employee_time_record (
    time_record_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    work_date DATE NOT NULL,
    hours_worked DECIMAL(4,2) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT chk_hours_worked CHECK (hours_worked BETWEEN 0 AND 24)
);

CREATE TABLE supplier (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL UNIQUE,
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL UNIQUE,
    item_type VARCHAR(50) NOT NULL,
    unit_of_measure VARCHAR(30) NOT NULL
);

CREATE TABLE supplier_item (
    supplier_id INT NOT NULL,
    item_id INT NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (supplier_id, item_id),
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);

CREATE TABLE purchase_order (
    purchase_order_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    employee_id INT NOT NULL,
    order_date DATE NOT NULL,
    expected_delivery_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE purchase_order_item (
    purchase_order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity_ordered INT NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (purchase_order_id, item_id),
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_order(purchase_order_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id),
    CONSTRAINT chk_po_quantity CHECK (quantity_ordered > 0)
);

CREATE TABLE supplier_shipment (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id INT NOT NULL,
    shipping_date DATE NOT NULL,
    expected_arrival_date DATE NOT NULL,
    actual_arrival_date DATE,
    tracking_number VARCHAR(60),
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_order(purchase_order_id)
);

CREATE TABLE wine (
    wine_id INT AUTO_INCREMENT PRIMARY KEY,
    wine_name VARCHAR(100) NOT NULL,
    wine_type VARCHAR(50) NOT NULL,
    vintage_year YEAR,
    bottle_size_ml INT NOT NULL DEFAULT 750,
    unit_price DECIMAL(10,2) NOT NULL,
    UNIQUE (wine_name, vintage_year)
);

CREATE TABLE distributor (
    distributor_id INT AUTO_INCREMENT PRIMARY KEY,
    distributor_name VARCHAR(100) NOT NULL UNIQUE,
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE distributor_order (
    distributor_order_id INT AUTO_INCREMENT PRIMARY KEY,
    distributor_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    tracking_number VARCHAR(60),
    FOREIGN KEY (distributor_id) REFERENCES distributor(distributor_id)
);

CREATE TABLE distributor_order_item (
    distributor_order_id INT NOT NULL,
    wine_id INT NOT NULL,
    quantity_ordered INT NOT NULL,
    sale_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (distributor_order_id, wine_id),
    FOREIGN KEY (distributor_order_id) REFERENCES distributor_order(distributor_order_id),
    FOREIGN KEY (wine_id) REFERENCES wine(wine_id),
    CONSTRAINT chk_dist_quantity CHECK (quantity_ordered > 0)
);

CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NULL,
    wine_id INT NULL,
    inventory_type VARCHAR(20) NOT NULL,
    quantity_on_hand INT NOT NULL DEFAULT 0,
    last_updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES item(item_id),
    FOREIGN KEY (wine_id) REFERENCES wine(wine_id),
    CONSTRAINT chk_inventory_owner CHECK (
        (item_id IS NOT NULL AND wine_id IS NULL AND inventory_type = 'SUPPLY') OR
        (item_id IS NULL AND wine_id IS NOT NULL AND inventory_type = 'DISTRIBUTION')
    )
);

CREATE TABLE sales_report (
    sales_report_id INT AUTO_INCREMENT PRIMARY KEY,
    distributor_id INT NOT NULL,
    wine_id INT NOT NULL,
    report_date DATE NOT NULL,
    quantity_sold INT NOT NULL,
    FOREIGN KEY (distributor_id) REFERENCES distributor(distributor_id),
    FOREIGN KEY (wine_id) REFERENCES wine(wine_id),
    UNIQUE (distributor_id, wine_id, report_date),
    CONSTRAINT chk_quantity_sold CHECK (quantity_sold >= 0)
);

-- Departments (6)
INSERT INTO department (department_name) VALUES
('Administration'), ('Production'), ('Warehouse'), ('Sales'), ('Shipping'), ('Accounting');

-- Employees (6)
INSERT INTO employee (department_id, first_name, last_name, job_title, email, hire_date) VALUES
(1,'Janet','Collins','Office Manager','jcollins@bacchuswinery.com','2021-03-15'),
(2,'David','Ortiz','Winemaker','dortiz@bacchuswinery.com','2020-06-01'),
(3,'Monica','Lee','Inventory Specialist','mlee@bacchuswinery.com','2022-01-10'),
(4,'Andre','Williams','Sales Coordinator','awilliams@bacchuswinery.com','2023-04-17'),
(5,'Sarah','Nguyen','Shipping Clerk','snguyen@bacchuswinery.com','2022-09-12'),
(6,'Marcus','Reed','Accountant','mreed@bacchuswinery.com','2021-11-08');

-- Employee time records (12 records spanning four quarters)
INSERT INTO employee_time_record (employee_id, work_date, hours_worked) VALUES
(1,'2025-10-15',8.00),(2,'2025-10-15',8.00),(3,'2026-01-15',8.00),
(4,'2026-01-15',7.50),(5,'2026-04-15',8.00),(6,'2026-04-15',8.00),
(1,'2026-07-15',8.00),(2,'2026-07-15',8.00),(3,'2026-07-16',7.50),
(4,'2026-07-16',8.00),(5,'2026-07-17',8.00),(6,'2026-07-17',7.50);

-- Bacchus case study uses three suppliers
INSERT INTO supplier (supplier_name, contact_name, phone, email) VALUES
('Bottle & Cork Supply Co.','Elena Brooks','555-210-1001','elena@bottlecork.example'),
('Vineyard Packaging Group','Thomas Grant','555-210-1002','thomas@vpg.example'),
('Winery Essentials LLC','Rosa Martinez','555-210-1003','rosa@wineryessentials.example');

-- Supply items (6)
INSERT INTO item (item_name, item_type, unit_of_measure) VALUES
('750ml Glass Bottle','Packaging','case'),
('Natural Cork','Packaging','bag'),
('Wine Label Roll','Packaging','roll'),
('Shipping Carton','Shipping','bundle'),
('Oak Barrel','Production','barrel'),
('Sanitizing Solution','Production','gallon');

INSERT INTO supplier_item (supplier_id, item_id, unit_cost) VALUES
(1,1,28.50),(1,2,42.00),(2,3,19.75),(2,4,31.25),(3,5,875.00),(3,6,24.50),
(2,1,29.25),(3,2,43.00);

-- Purchase orders (6)
INSERT INTO purchase_order (supplier_id, employee_id, order_date, expected_delivery_date, status) VALUES
(1,3,'2026-08-01','2026-08-08','Received'),
(2,3,'2026-08-05','2026-08-12','Received'),
(3,2,'2026-08-10','2026-08-20','Received'),
(1,3,'2026-09-01','2026-09-08','Received'),
(2,3,'2026-09-05','2026-09-12','In Transit'),
(3,2,'2026-09-10','2026-09-20','Ordered');

INSERT INTO purchase_order_item (purchase_order_id, item_id, quantity_ordered, unit_cost) VALUES
(1,1,20,28.50),(1,2,10,42.00),(2,3,15,19.75),(2,4,12,31.25),
(3,5,6,875.00),(3,6,12,24.50),(4,1,18,28.50),(4,2,8,42.00),
(5,3,20,19.75),(5,4,15,31.25),(6,5,4,875.00),(6,6,10,24.50);

INSERT INTO supplier_shipment (purchase_order_id, shipping_date, expected_arrival_date, actual_arrival_date, tracking_number) VALUES
(1,'2026-08-03','2026-08-08','2026-08-08','SUP1001'),
(2,'2026-08-07','2026-08-12','2026-08-14','SUP1002'),
(3,'2026-08-14','2026-08-20','2026-08-19','SUP1003'),
(4,'2026-09-03','2026-09-08','2026-09-09','SUP1004'),
(5,'2026-09-08','2026-09-12',NULL,'SUP1005'),
(6,'2026-09-12','2026-09-20',NULL,'SUP1006');

-- Wines (6)
INSERT INTO wine (wine_name, wine_type, vintage_year, bottle_size_ml, unit_price) VALUES
('Bacchus Cabernet Reserve','Cabernet Sauvignon',2022,750,28.00),
('Bacchus Merlot','Merlot',2023,750,24.00),
('Bacchus Chardonnay','Chardonnay',2024,750,22.00),
('Bacchus Pinot Noir','Pinot Noir',2023,750,27.00),
('Bacchus Riesling','Riesling',2024,750,21.00),
('Bacchus Rose','Rose',2025,750,20.00);

-- Distributors (6)
INSERT INTO distributor (distributor_name, contact_name, phone, email) VALUES
('Suncoast Wine Distribution','Rachel King','555-310-2001','rking@suncoast.example'),
('Metro Beverage Partners','Kevin Young','555-310-2002','kyoung@metro.example'),
('Heritage Wine Supply','Laura Adams','555-310-2003','ladams@heritage.example'),
('Coastal Cellars Distribution','Brian Scott','555-310-2004','bscott@coastal.example'),
('Premier Restaurant Supply','Angela Hill','555-310-2005','ahill@premier.example'),
('Regional Wine Merchants','Carlos Diaz','555-310-2006','cdiaz@regional.example');

INSERT INTO distributor_order (distributor_id, order_date, order_status, tracking_number) VALUES
(1,'2026-09-01','Shipped','DIST2001'),(2,'2026-09-02','Delivered','DIST2002'),
(3,'2026-09-03','Processing',NULL),(4,'2026-09-04','Shipped','DIST2004'),
(5,'2026-09-05','Delivered','DIST2005'),(6,'2026-09-06','Processing',NULL);

INSERT INTO distributor_order_item (distributor_order_id, wine_id, quantity_ordered, sale_price) VALUES
(1,1,24,25.00),(1,3,18,19.50),(2,2,30,21.50),(2,6,24,18.00),
(3,4,18,24.50),(3,5,24,18.50),(4,1,12,25.00),(4,4,18,24.50),
(5,3,30,19.50),(5,6,36,18.00),(6,2,24,21.50),(6,5,18,18.50);

-- Inventory: six supply records and six distribution records
INSERT INTO inventory (item_id, wine_id, inventory_type, quantity_on_hand) VALUES
(1,NULL,'SUPPLY',42),(2,NULL,'SUPPLY',28),(3,NULL,'SUPPLY',35),
(4,NULL,'SUPPLY',26),(5,NULL,'SUPPLY',10),(6,NULL,'SUPPLY',18),
(NULL,1,'DISTRIBUTION',120),(NULL,2,'DISTRIBUTION',145),(NULL,3,'DISTRIBUTION',132),
(NULL,4,'DISTRIBUTION',98),(NULL,5,'DISTRIBUTION',110),(NULL,6,'DISTRIBUTION',156);

INSERT INTO sales_report (distributor_id, wine_id, report_date, quantity_sold) VALUES
(1,1,'2026-08-31',18),(1,3,'2026-08-31',14),(2,2,'2026-08-31',25),
(2,6,'2026-08-31',20),(3,4,'2026-08-31',12),(3,5,'2026-08-31',16),
(4,1,'2026-08-31',10),(4,4,'2026-08-31',13),(5,3,'2026-08-31',22),
(5,6,'2026-08-31',29),(6,2,'2026-08-31',17),(6,5,'2026-08-31',11);

-- Useful quarterly-hours report for the last four quarters
SELECT e.employee_id,
       CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
       YEAR(t.work_date) AS work_year,
       QUARTER(t.work_date) AS work_quarter,
       SUM(t.hours_worked) AS total_hours
FROM employee e
JOIN employee_time_record t ON e.employee_id = t.employee_id
GROUP BY e.employee_id, employee_name, YEAR(t.work_date), QUARTER(t.work_date)
ORDER BY work_year, work_quarter, e.employee_id;
