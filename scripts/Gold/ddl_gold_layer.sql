--Gold layer
--Data Integration

--This is a dimension table about customers 
create view gold.dim_customers as

SELECT
ROW_NUMBER() over (order by ci.cust_id) as 'Customer Key', --surrogate key : system genereated unique identifier to identify each record 
ci.cust_id as 'Customer ID',
ci.cust_key as 'Customer Number',
ci.cust_firstname as 'First Name',
ci.cust_lastname as 'Last Name',
la.country as 'Country',
case 
     when ci.cust_gender!='Unknown' then ci.cust_gender
	 else ISNULL(cust_gender,'Unknown')
end Gender,
ci.cust_marital_status as 'Marital Status',
ca.bdate as 'Birth Date',
ci.cust_date as 'Create Date'
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cust_key = ca.cid
LEFT JOIN silver.erp_oc_a101 la
ON ci.cust_key = la.cid



--check there is no duplicates
SELECT cust_id, COUNT(*) FROM
(SELECT
ci.cust_id,
ci.cust_key,
ci.cust_firstname,
ci.cust_lastname,
ci.cust_marital_status,
ci.cust_gender,
ci.cust_date,
ca.bdate,
ca.gen,
la.country
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cust_key = ca.cid
LEFT JOIN silver.erp_oc_a101 la
ON ci.cust_key = la.cid
)t GROUP BY cust_id
HAVING COUNT(*) > 1

select distinct 
ci.cust_gender,
ca.gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cust_key = ca.cid
LEFT JOIN silver.erp_oc_a101 la
ON ci.cust_key = la.cid   
--we notice here that row number 2 cust_gender != gen but we had asked experts and say CRM is the master table so its info is more correct

create view gold.dim_products as
SELECT
ROW_NUMBER() over (order by pn.prd_id) as 'Product Key', --surrogate key : system genereated unique identifier to identify each record 

pn.prd_id as 'Product ID',
pn.cat_id as 'Category ID',
pn.prd_key as 'Product Number',
pn.prd_name as 'Product Name',
pc.cat as 'Category',
pc.subcat as 'SubCategory',
pc.maintenance as 'Maintenance',
pn.prd_cost as 'Cost',
pn.prd_line as 'Product Line',
pn.prd_start_dt as 'Product Start Date'
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL --filter out all historical data

create view gold.fact_sales as
SELECT
sd.sls_ord_num as 'Order Number',
pr.[Product Key],
cu.[Customer Key],
sd.sls_order_dt as 'Order Date',
sd.sls_ship_dt as 'Shipping Date',
sd.sls_due_dt as 'Due Date',
sd.sls_sales as Sales,
sd.sls_quantity as Quantity,
sd.sls_price as Price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.[Product Number]
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.[Customer ID]
