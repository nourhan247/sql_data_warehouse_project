--This stored procedure performs the ETL process to populate silver schema tables from bronze schema
--using :- exec silver.load_silver

create or alter procedure silver.load_silver as
begin
        declare @start_batching datetime , @end_batching datetime , @start_time datetime , @end_time datetime
		begin try
		set @start_batching=GETDATE()
		print '************************************************' ;
		print 'Loading Bronze Layer';
		print '************************************************' ;
		print '-----------------------------------------------' ;
		print 'Loading CRM Data';
		print '-----------------------------------------------' ;
		set @start_time = getdate()
		print 'Truncating Table: silver.crm_cust_info';
		truncate table silver.crm_cust_info;
		print 'Inserting data into: silver.crm_cust_info';
		insert into silver.crm_cust_info(cust_id,cust_key,cust_firstname,cust_lastname,cust_marital_status,cust_gender,cust_date)
		select   cust_id,
		  cust_key ,
		  trim(cust_firstname) as cust_firstname,  --Data consistency
		  trim(cust_lastname) as cust_lastname ,
		 case 
			  when UPPER(trim(cust_marital_status))='S' then 'Single'
			  when UPPER(trim(cust_marital_status))='M' then 'Male'
			  else 'Unkown'
		end cust_marital_status,   --Normalization 

		  case 
			  when UPPER(trim(cust_gender))='F' then 'Female'
			  when UPPER(trim(cust_gender))='M' then 'Male'
			  else 'Unkown'
		end cust_gender,
		  cust_date
		from(
		select * , ROW_NUMBER() over (partition by cust_id order by cust_date) as latest
		from bronze.crm_cust_info
		where cust_id is not null) t 
		where latest=1;     --remove duplicates and null values 
		set @end_time = getdate()
		print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
	    print '----------'

		------------------------------------------------------------------------------------------------------
		--Product table
		set @start_time = getdate()
		print 'Truncating Table: silver.crm_prd_info';
		truncate table silver.crm_prd_info;
		print 'Inserting data into: silver.crm_prd_info';
		insert into silver.crm_prd_info(prd_id,cat_id,prd_key,prd_name,prd_cost,prd_line,prd_start_dt,prd_end_dt)

		select prd_id,
		REPLACE(SUBSTRING(prd_key,1,5) ,'-','_') as prd_cat,
		SUBSTRING(prd_key,7,len(prd_key)) as prd_key, --notice the same thing but with sales table 
		prd_name,
		isnull(prd_cost,0) as prd_cost,
		case UPPER(trim(prd_line))
			when 'M' then 'Mountain'
			when 'R' then 'Road'
			when 'S' then 'Other Sales'
			when 'T' then 'Touring'
			else 'Unknown'
		end prd_line,

		cast(prd_start_dt as date) as prd_start_dt,
		cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date)as prd_end_dt  --data enrichment adding new relevant data to enhance dataset

		from bronze.crm_prd_info;
		set @end_time = getdate()
		print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
	    print '----------'

		--------------------------------------------------------------------------------------------------------------------------------
		--Sales table
		set @start_time = getdate()
		print 'Truncating Table: silver.crm_sales_details';
		truncate table silver.crm_sales_details;
		print 'Inserting data into: silver.crm_sales_details';
		insert into silver.crm_sales_details(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price)

		select 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		case 
			 when sls_order_dt =0 or len(sls_order_dt) !=8 then null
			 else cast(cast(sls_order_dt as varchar)as date)  --we can't directly convert int to date we should first convert in into string then date
		end as sls_order_dt,
		case 
			 when sls_ship_dt =0 or len(sls_ship_dt) !=8 then null
			 else cast(cast(sls_ship_dt as varchar)as date)  --we can't directly convert int to date we should first convert in into string then date
		end as sls_ship_dt,
		case 
			 when sls_due_dt =0 or len(sls_due_dt) !=8 then null
			 else cast(cast(sls_due_dt as varchar)as date)  --we can't directly convert int to date we should first convert in into string then date
		end as sls_due_dt,
		case
			when sls_sales <=0 or sls_sales is null or sls_sales!= sls_quantity * ABS(sls_price) then sls_quantity * ABS(sls_price)
			else sls_sales
		end sls_sales,
		sls_quantity,
		case
			when sls_price <=0 or sls_price is null then sls_sales / nullif(sls_quantity,0)
			else sls_price
		end sls_price

		from bronze.crm_sales_details
		set @end_time = getdate()
		print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
	    print '----------'
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--erp_cust_az12
		set @start_time = getdate()

		print 'Truncating Table: silver.erp_cust_az12';
		truncate table silver.erp_cust_az12;
		print 'Inserting data into: silver.erp_cust_az12';
		insert into silver.erp_cust_az12(
		cid,
		bdate,
		gen
		)
		select
		 case
			when cid like 'NAS%' then SUBSTRING(cid,4,len(cid)) 
			else cid
		end cid,   --remove NAS prefix if present
		case 
			when bdate>GETDATE() then null 
			else bdate
		end bdate, --handle invalid values
		case 
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'Unknown'
		end gen  --normalization 
		from bronze.erp_cust_az12

		set @end_time = getdate()
		print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
	    print '----------'

		------------------------------------------------------------------------------------------------------------------------------------------------
		--erp_oc_a101
		set @start_time = getdate()
		print 'Truncating Table: silver.erp_oc_a101';
		truncate table silver.erp_oc_a101;
		print 'Inserting data into: silver.erp_oc_a101';
		insert into silver.erp_oc_a101(cid,country)
		 select 
		 REPLACE(cid,'-','') as cid ,
		 case 
			 when upper(trim(country)) in ('US','USA') then 'United Kingdom'  
			 when upper(trim(country))='DE' then 'Germany'  
			 when trim(country)='' or trim(country) is null then 'Unknown'  
			 else trim(country)
		end country
		from bronze.erp_oc_a101
		set @end_time = getdate()
		print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
	    print '----------'
		--------------------------------------------------------------------------------------------------------------------------
		--erp_px_cat_g1v2 table
		set @start_time = getdate()
		print 'Truncating Table: silver.erp_px_cat_g1v2';
		truncate table silver.erp_px_cat_g1v2;
		print 'Inserting data into: silver.erp_px_cat_g1v2';
		insert into silver.erp_px_cat_g1v2(
		id,
		cat,
		subcat,
		maintenance
		)
         select *from bronze.erp_px_cat_g1v2
		 set @end_time = getdate()
		 print 'Load duration: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds';
	     print '----------'
				SET @end_batching=GETDATE();
				print '------------------------------------------';
				print ' Loading Silver Layer is Completed';
				print 'Total Load Duraton: ' +cast(datediff(second,@start_batching,@end_batching) as nvarchar) + ' seconds';
				print '------------------------------------------';

         end try

		 begin catch
		             print '============================================';
		             print 'Error Occured during loading Silver layer';
		             print 'Error Message' + error_message();
		             print 'Error Number' + cast(error_number() as nvarchar);
		             print 'Error State' + cast(error_state() as nvarchar);
		             print '============================================'
         end catch

end
