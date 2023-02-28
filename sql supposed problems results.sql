select * from sales where amount > 2000 and boxes < 100;

/*same results*/
select p.Salesperson, count(*) as 'Shipment Count'
from sales s
join people p on s.spid = p.spid
where month(saledate)=1 and year(saledate)=2022
group by p.Salesperson
order by count(*) desc;

select p.Salesperson, count(*) as 'Shipment Count'
from sales s
join people p on s.spid = p.spid
where SaleDate between '2022-1-1' and '2022-1-31'
group by p.Salesperson
order by count(*) desc;

select p.salesperson, s.amount, s.boxes, s.saledate, 
count(*) over (partition by p.Salesperson) shipment_count, 
case when  month(saledate)=1 then 'january 2022' else '' end as sales_month
from sales s
left join people p 
on p.spid=s.spid
where month(saledate)=1 and year(saledate)=2022
order by shipment_count desc;

/*still same result but written in another way*/

with former_table as (
select p.salesperson, 
count(*) over (partition by p.Salesperson) shipment_count, 
case when  month(saledate)=1 then 'january 2022' else '' end as sales_month
from sales s
left join people p 
on p.spid=s.spid
where month(saledate)=1 and year(saledate)=2022)
select salesperson, sales_month, count(shipment_count)
from former_table
group by salesperson, sales_month
order by shipment_count desc;

--

select pr.product, sum(boxes) as 'Total Boxes'
from sales s
join products pr on s.pid = pr.pid 
where pr.Product in ('Milk Bars', 'Eclairs')
and s.saledate between '2022-2-1' and '2022-2-7'
group by pr.product;

select * from sales
where customers < 100 and boxes < 100;

select *,
case when weekday(saledate)='2' then 'Wednesday Shipment'
else ''
end as 'W Shipment'
from sales
where customers < 100 and boxes < 100;

/*salesperson with at least one shipment in the first 7 days of jan 2022*/
with result as (
select p.salesperson,count(*) shipment_count ,day(saledate) days
from sales s
left join people p 
on p.spid=s.spid
where saledate between '2022-1-1' and '2022-1-7' 
group by p.salesperson)
select salesperson, shipment_count, days
from result
where shipment_count=1




select distinct count(p.Salesperson)
from sales s
join people p on p.spid = s.SPID
where s.SaleDate between '2022-01-01' and '2022-01-07';

select p.salesperson
from people p
where p.spid not in
(select distinct s.spid from sales s where s.SaleDate between ‘2022-01-01’ and ‘2022-01-07’);

select year(saledate) 'Year', month(saledate) 'month', count(*) 'Times we shipped >1k boxes'
from sales
where boxes>1000
group by year(saledate), month(saledate)
order by year(saledate), month(saledate);

set @product_name = 'After Nines';
set @country_name = 'New Zealand';
select year(saledate) 'Year', month(saledate) 'Month',
if(sum(boxes)>1, 'Yes','No') 'Status'
from sales s
join products pr on pr.PID = s.PID
join geo g on g.GeoID=s.GeoID
where pr.Product = @product_name and g.Geo = @country_name
group by year(saledate), month(saledate)
order by year(saledate), month(saledate);

select year(saledate) 'Year', month(saledate) 'Month',
sum(CASE WHEN g.geo='India' = 1 THEN boxes ELSE 0 END) 'India Boxes',
sum(CASE WHEN g.geo='Australia' = 1 THEN boxes ELSE 0 END) 'Australia Boxes'
from sales s
join geo g on g.GeoID=s.GeoID
group by year(saledate), month(saledate)
order by year(saledate), month(saledate);


select year(saledate) ‘Year’, month(saledate) ‘Month’,
sum(CASE WHEN g.geo=’India’ = 1 THEN boxes ELSE 0 END) ‘India Boxes’,
sum(CASE WHEN g.geo=’Australia’ = 1 THEN boxes ELSE 0 END) ‘Australia Boxes’
from sales s
join geo g on g.GeoID=s.GeoID
group by year(saledate), month(saledate)
order by year(saledate), month(saledate);


