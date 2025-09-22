CREATE SCHEMA bronze;

if OBJECT_ID('bronze.crm_cust_info','U') is not null
    drop table bronze.crm_cust_info;

create table bronze.crm_cust_info(
  cust_id int,
  cust_key nvarchar(50),
  cust_firstname nvarchar(50),
  cust_lastname nvarchar(50),
  cust_marital_status nvarchar(50),
  cust_gender nvarchar(10),
  cust_date date
);


if OBJECT_ID('bronze.crm_prd_info','U') is not null
    drop table bronze.crm_prd_info;

create table bronze.crm_prd_info(
prd_id int,
prd_key nvarchar(50),
prd_name nvarchar(50),
prd_cost int,
prd_line nvarchar(50),
prd_start_dt datetime,
prd_end_dt datetime
);

if OBJECT_ID('bronze.crm_sales_details','U') is not null
    drop table bronze.crm_sales_details;

create table bronze.crm_sales_details(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales int,
sls_quantity int,
sls_price int
);

if OBJECT_ID('bronze.erp_oc_a101','U') is not null
    drop table bronze.erp_oc_a101;

create table bronze.erp_oc_a101(
cid nvarchar(50),
country nvarchar(50)
);

GO

if OBJECT_ID('bronze.erp_cust_az12','U') is not null
    drop table bronze.erp_cust_az12;

create table bronze.erp_cust_az12(
cid nvarchar(50),
bdate date,
gen nvarchar(50)
);

GO

if OBJECT_ID('bronze.erp_px_cat_g1v2','U') is not null
    drop table bronze.erp_px_cat_g1v2;

create table bronze.erp_px_cat_g1v2(
id nvarchar(50),
cat nvarchar(50),
subcat nvarchar(50),
maintenance nvarchar(50)
);

