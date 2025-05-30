create database supply_chain;
use supply_chain;


create table dim_inventory (product_id varchar(10) primary key,
    store_id varchar(10),
    warehouse_id varchar(10),
    stock_level int,
    reorder_level int,
    last_updated date
);

create table dim_suppliers (supplier_id varchar(10) primary key,
    supplier_name varchar(50),
    product_id varchar(10),
    lead_time_days int,
    order_frequency varchar(10)
);

create table dim_purchase_orders (order_id varchar(10) primary key,
    product_id varchar(10),
    supplier_id varchar(10),
    order_date date,
    quantity int,
    arrival_date date
);

create table fact_sales (sale_id int primary key,
    product_id varchar(10),
    supplier_id varchar(10),
    order_id varchar(10),
    store_id varchar(10),
    sale_date date,
    quantity_sold int,
    revenue int,
    foreign key (product_id) references dim_inventory(product_id),
	foreign key (supplier_id) references dim_suppliers(supplier_id),
	foreign key (order_id) references dim_purchase_orders(order_id)
);

insert into dim_purchase_orders (order_id, product_id, supplier_id, order_date, quantity, arrival_date)
values
('PO1001', 'P001', 'SUP001', '2024-11-01', 100, '2024-11-06'),
('PO1002', 'P002', 'SUP002', '2024-12-05', 200, '2024-12-12'),
('PO1003', 'P003', 'SUP003', '2024-11-02', 200, '2024-11-12'),
('PO1004', 'P005', 'SUP006', '2024-12-05', 200, '2024-12-11'),
('PO1005', 'P002', 'SUP007', '2025-01-06', 200, '2025-01-13'),
('PO1006', 'P001', 'SUP008', '2025-02-07', 200, '2025-02-18'),
('PO1007', 'P006', 'SUP009', '2025-02-25', 200, '2025-03-01'),
('PO1008', 'P007', 'SUP010', '2025-01-28', 200, '2025-02-02'),
('PO1009', 'P003', 'SUP004', '2025-02-05', 200, '2025-02-09'),
('PO1010', 'P004', 'SUP005', '2025-01-03', 200, '2025-01-12');

select * from dim_purchase_orders;

insert into dim_suppliers (supplier_id, supplier_name, product_id, lead_time_days, order_frequency)
values ('SUP001', 'ABC Ltd', 'P001', 5, 'Weekly'),
('SUP002', 'XYZ Co', 'P002', 7, 'Biweekly'),
('SUP003', 'PQR Ltd', 'P003', 5, 'Biweekly'),
('SUP004', 'LMN Co', 'P003', 7, 'Weekly'),
('SUP005', 'RST Ltd', 'P004', 3, 'Biweekly'),
('SUP006', 'UVW Co', 'P005', 8, 'Monthly'),
('SUP007', 'EFG Ltd', 'P002', 5, 'Weekly'),
('SUP008', 'HIJ Co', 'P001', 6, 'Biweekly'),
('SUP009', 'KLM Ltd', 'P006', 4, 'Weekly'),
('SUP010', 'NOP Co', 'P007', 7, 'Monthly');

select * from dim_suppliers;


insert into dim_inventory (product_id, store_id, warehouse_id, stock_level, reorder_level, last_updated)
values ('P001', 'S101', 'W001', 50, 100, '2025-02-18'),
('P002', 'S102', 'W002', 200, 150, '2025-01-13'),
('P003', 'S103', 'W003', 150, 100, '2025-02-09'),
('P004', 'S104', 'W002', 220, 180, '2025-01-12'),
('P005', 'S105', 'W003', 190, 140, '2024-12-11'),
('P006', 'S101', 'W001', 210, 160, '2025-03-01'),
('P007', 'S102', 'W002', 170, 130, '2025-02-02'),
('P008', 'S103', 'W003', 230, 100, '2024-12-15'),
('P009', 'S104', 'W001', 140, 90, '2024-11-15'),
('P010', 'S105', 'W002', 250, 120, '2024-10-28');

select * from dim_inventory;


insert into fact_sales (sale_id,  order_id, product_id, supplier_id, store_id,sale_date, quantity_sold, revenue)
values (1001, 'PO1001', 'P001', 'SUP001', 'S101', '2025-02-20', 40, 6000),
(1002, 'PO1002', 'P002', 'SUP002', 'S102', '2025-01-15', 150, 22500),
(1003, 'PO1003', 'P003', 'SUP003', 'S103', '2025-02-10', 120, 18000),
(1004, 'PO1004', 'P005', 'SUP006', 'S105', '2024-12-13', 180, 27000),
(1005, 'PO1005', 'P002', 'SUP007', 'S102', '2025-02-03', 100, 15000),
(1006, 'PO1006', 'P001', 'SUP008', 'S101', '2025-03-02', 50, 7500),
(1007, 'PO1007', 'P006', 'SUP009', 'S101', '2025-03-03', 200, 30000),
(1008, 'PO1008', 'P007', 'SUP010', 'S102', '2025-02-05', 170, 25500),
(1009, 'PO1009', 'P003', 'SUP004', 'S103', '2024-12-20', 130, 19500),
(1010, 'PO1010', 'P004', 'SUP005', 'S104', '2024-11-20', 140, 21000);

select * from fact_sales;

# fast-moving products

select product_id, sum(quantity_sold) from fact_sales  where sale_date >= date_sub(curdate(), interval 3 month)
group by product_id order by sum(quantity_sold) desc;


# slow-moving products 

select product_id, sum(quantity_sold) from fact_sales  where sale_date >= date_sub(curdate(), interval 3 month)
group by product_id order by sum(quantity_sold) asc;

# products below reorder level – Generate a report listing products that need restocking.

select product_id, store_id, stock_level, reorder_level from dim_inventory where stock_level < reorder_level;

# Supplier lead time analysis – Find suppliers with high lead times and suggest alternatives.

select supplier_id, supplier_name, product_id, lead_time_days from dim_suppliers 
where lead_time_days > (select avg(lead_time_days) from dim_suppliers) order by lead_time_days desc;

# alternatives

select s1.supplier_id as high_supplier,  s1.supplier_name as high_supplier_name,  s1.product_id, s1.lead_time_days as high_lead_time,
s2.supplier_id as  alt_supplier, s2.supplier_name  as alt_supplier_name, s2.lead_time_days as alt_lead_time  from dim_suppliers s1 join
dim_suppliers s2 on s1.product_id = s2.product_id where
s1.lead_time_days > (select avg(lead_time_days) from dim_suppliers)
and s1.lead_time_days > s2.lead_time_days and s2.lead_time_days = ( select min(s3.lead_time_days) from dim_suppliers s3 where
s3.product_id = s1.product_id and s3.lead_time_days < s1.lead_time_days);
