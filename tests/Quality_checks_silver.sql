
--check for data quality

select cust_id , count(*)
from silver.crm_cust_info
group by cust_id
having count(*)>1 or cust_id is Null

select cust_firstname
from silver.crm_cust_info
where cust_firstname != trim(cust_firstname)

select distinct cust_gender
from silver.crm_cust_info

--check for data quality
select prd_cost 
from silver.crm_prd_info
where prd_cost<0 or prd_cost is null

select distinct(prd_line) from silver.crm_prd_info

select * from silver.crm_prd_info

		
--check for date vaildation
select * from silver.crm_sales_details
where sls_order_dt>sls_ship_dt or sls_order_dt>sls_due_dt
select * from silver.crm_sales_details
where sls_sales <=0 or sls_sales is null or sls_sales!=sls_quantity * ABS(sls_price)

select * from silver.crm_sales_details

--check for data consistency
select distinct gen from silver.erp_cust_az12

select *
from bronze.erp_px_cat_g1v2
