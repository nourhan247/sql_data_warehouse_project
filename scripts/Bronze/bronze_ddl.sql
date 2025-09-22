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

--Instead of writing the same SQL repeatedly, you can call the procedure by name.
create or alter procedure bronze.load_bronze as
begin
     declare @start_time datetime , @end_time datetime , @batch_start_time datetime ,@batch_end_time datetime
     begin try
	           SET @batch_start_time=GETDATE();
				print '***********************************************' ;
				print 'Loading Bronze Layer';
				print '***********************************************' ;
				print '-----------------------------------------------' ;
				print 'Loading CRM Data';
				print '-----------------------------------------------' ;
				set @start_time = getdate()
				print 'Truncating Table: bronze.crm_cust_info';
				truncate table bronze.crm_cust_info;
				print 'Inserting data into: bronze.crm_cust_info';
				bulk insert bronze.crm_cust_info
				from 'D:\Data Warehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
				with(
				firstrow=2,
				fieldterminator=',',
				tablock
				);
				set @end_time = getdate()
				print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
				print '----------'

				set @start_time = getdate()
				print 'Truncating Table: bronze.crm_prd_info';
				truncate table bronze.crm_prd_info;
				print 'Inserting data into: bronze.crm_prd_info';
				bulk insert bronze.crm_prd_info
				from 'D:\Data Warehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
				with(
				firstrow=2,
				fieldterminator=',',
				tablock
				);
				set @end_time = getdate()
				print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
				print '----------'
				set @start_time = getdate()
				print 'Truncating Table: bronze.crm_sales_details';
				truncate table bronze.crm_sales_details;
				print 'Inserting data into: bronze.crm_sales_details';
				bulk insert bronze.crm_sales_details
				from 'D:\Data Warehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
				with(
				firstrow=2,
				fieldterminator=',',
				tablock
				);
				set @end_time = getdate()
				print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
				print '----------'
				print '-----------------------------------------------' ;
				print 'Loading ERP Data';
				set @start_time = getdate()
				print '-----------------------------------------------' ;
				print 'Truncating Table: bronze.erp_cust_az12';
				truncate table bronze.erp_cust_az12;
				print 'Inserting data into: bronze.erp_cust_az12';
				bulk insert bronze.erp_cust_az12
				from 'D:\Data Warehouse\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
				with(
				firstrow=2,
				fieldterminator=',',
				tablock
				);
				set @end_time = getdate()
				print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
				print '----------'
				set @start_time = getdate()
				print 'Truncating Table: bronze.erp_oc_a101';
				truncate table bronze.erp_oc_a101;
				print 'Inserting data into: bronze.erp_oc_a101';
				bulk insert bronze.erp_oc_a101
				from 'D:\Data Warehouse\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
				with(
				firstrow=2,
				fieldterminator=',',
				tablock
				);
				set @end_time = getdate()
				print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
				print '----------'
				set @start_time = getdate()
				print 'Truncating Table: bronze.erp_px_cat_g1v2';
				truncate table bronze.erp_px_cat_g1v2;
				print 'Inserting data into: bronze.erp_px_cat_g1v2';
				bulk insert bronze.erp_px_cat_g1v2
				from 'D:\Data Warehouse\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
				with(
				firstrow=2,
				fieldterminator=',',
				tablock
				);
				set @end_time = getdate()
				print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
				print '----------'
				SET @batch_end_time=GETDATE();
				print '------------------------------------------';
				print ' Loading Bronze Layer is Completed';
				print 'Total Load Duraton: ' +cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + ' seconds';
				print '------------------------------------------';

         end try

		 begin catch
		             print '============================================';
		             print 'Error Occured during loading bronze layer';
		             print 'Error Message' + error_message();
		             print 'Error Number' + cast(error_number() as nvarchar);
		             print 'Error State' + cast(error_state() as nvarchar);
		             print '============================================'
         end catch

end 
