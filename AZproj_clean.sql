--cleaning script
--cust_info table cleaned
create view crm.cust_clean as
select 
	cst_id,
	cst_key,
	trim(cst_firstname) as cst_firstname,
	trim(cst_lastname) as cst_lastname,
		case
		when upper(cst_marital_status) = 'M' then 'Married'
		when upper(cst_marital_status) = 'S' then 'Single'
		else 'n/a'
	end as cst_marital_status,
	case
		when upper(cst_gndr) = 'M' then 'Male'
		when upper(cst_gndr) = 'F' then 'Female'
		else 'n/a'
	end as cst_gndr,
	cst_create_date
from (
		select 
		*,
		row_number() over(partition by cst_id order by cst_create_date desc) as no_rows
	from crm.cust_info
	where cst_id is not null
)a
where no_rows = 1;

--prd_info cleaning
create view crm.prd_clean as 
select
	prd_id,
	replace(substring(prd_key, 1, 5), '-', '_') as cat_id,
	substring(prd_key, 7, length(prd_key)) as prd_key,
	prd_nm,
	coalesce(prd_cost, 0) as prd_cost,
	case
		when upper(trim(prd_line)) = 'M' then 'Mountain'
		when upper(trim(prd_line)) = 'R' then 'Road'
		when upper(trim(prd_line)) = 'S' then 'Other sales'
		when upper(trim(prd_line)) = 'T' then 'Touring'
		else 'n/a'
	end as prd_line,
	prd_start_dt,
	lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as prd_end_date
from crm.prd_info;
		

--sales_details
create view crm.sales_clean as 
select 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case 
		when cast(sls_order_dt as integer) = 0 or length(sls_order_dt) != 8 then null
		else cast(sls_order_dt as date)
	end as sls_order_dt,
	case 
		when cast(sls_ship_dt as integer) = 0 or length(sls_ship_dt) != 8 then null
		else cast(sls_ship_dt as date)
	end as sls_ship_dt,
	case 
		when cast(sls_due_dt as integer) = 0 or length(sls_due_dt) != 8 then null
		else cast(sls_due_dt as date)
	end as sls_due_dt,
	case 
		when sls_sales is null or sls_sales <= 0 or sls_sales != (sls_quantity * ABS(sls_price)) 
			then (sls_quantity * ABS(sls_price))
		else sls_sales
	end as sls_sales,
	sls_quantity,
	case 
		when sls_price is null or sls_price <= 0 or sls_price != (sls_sales/sls_quantity)
			then (sls_sales/sls_quantity)
		else sls_price
	end sls_price
from crm.sales_details;

--clean prod_category
create view crm.cat_clean as 
select 
	id,
	trim(cat) as prod_cat,
	trim(subcat) as prod_subcat,
	trim(maintenance) as maintenance
from crm.prod_cat;

---loc_info cleaned
create view crm.loc_clean as 
select 
	substring(cid, 1, 6) as cus_key,
	substring(cid, 7, length(cid)) as cst_id,
	trim(cntry) as country
from crm.loc_info;

--customer details cleaned
create view crm.custdetail_clean as
select
	cid,
	bdate,
	case 
		when upper(trim(gen)) = 'M' then 'Male'
		when upper(trim(gen)) = 'F' then 'Female'
		when upper(trim(gen)) = 'null' then 'n/a'
        else gen
	end as cust_gender
from crm.cust_det;

select
	*
from crm.sales_clean;

select 
	*
from crm.cust_info

select 
	* 
from crm.loc_clean;

		
	