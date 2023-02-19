/* 
cleaning data in sql witht queries
*/

select *
from Portfolioproject.dbo.housingdata

--standardize date format
select saledate, convert(date,saledate),/*or*/ cast(saledate as date)
from Portfolioproject.dbo.housingdata

update Portfolioproject.dbo.housingdata
set saledate=convert(date,saledate)

--or lets do it this way
alter table Portfolioproject.dbo.housingdata
add saledateconverted date

update Portfolioproject.dbo.housingdata
set saledateconverted=convert(date,saledate)

--populate property address data

select *
from Portfolioproject.dbo.housingdata
--where propertyaddress is null
order by parcelid

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
from Portfolioproject.dbo.housingdata A
join Portfolioproject.dbo.housingdata B
on a.parcelid=b.parcelid and a.uniqueid<>b.UniqueID
where a.propertyaddress is null

update a
set propertyaddress=ISNULL(a.propertyaddress,b.propertyaddress)
from Portfolioproject.dbo.housingdata A
join Portfolioproject.dbo.housingdata B
on a.parcelid=b.parcelid and a.uniqueid<>b.uniqueid
where a.propertyaddress is null


--Breaking out propertyaddress into individual columns (address, city, state)
select PropertyAddress
from Portfolioproject..housingdata
--breaking of the address from the propertyadress
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
from Portfolioproject..housingdata
--breaking of the city from the propertyadress
select 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
from Portfolioproject..housingdata
--adding of the new columns into the table
alter table Portfolioproject..housingdata
add Propertysplitaddress nvarchar(255)
alter table Portfolioproject..housingdata
add Propertysplitcity nvarchar(255)

--updating the two new column in the table
update Portfolioproject..housingdata
set Propertysplitaddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
update Portfolioproject..housingdata
set Propertysplitcity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--
--Breaking out owneraddress into individual columns (address, city, state) but using different method
select owneraddress,
parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from Portfolioproject..housingdata




alter table Portfolioproject..housingdata
add ownersplitaddress nvarchar(255)
alter table Portfolioproject..housingdata
add ownersplitcity nvarchar(255)
alter table Portfolioproject..housingdata
add ownersplitstate nvarchar(255)

update Portfolioproject..housingdata
set ownersplitaddress =parsename(replace(owneraddress,',','.'),3)
update Portfolioproject..housingdata
set ownersplitcity =parsename(replace(owneraddress,',','.'),2)
update Portfolioproject..housingdata
set ownersplitstate =parsename(replace(owneraddress,',','.'),1)

select *
from Portfolioproject..housingdata

--change y and x to "yes" anad "no" in the "sold as vacant" field\

select distinct soldasvacant
from Portfolioproject..housingdata


select soldasvacant, count(soldasvacant)
from Portfolioproject..housingdata
group by soldasvacant

select soldasvacant,
case when soldasvacant='y'then'yes'
		when soldasvacant='n' then 'no'
			else soldasvacant 
			end
from Portfolioproject..housingdata

update Portfolioproject..housingdata
set SoldAsVacant=case when soldasvacant='y'then'yes'
		when soldasvacant='n' then 'no'
			else soldasvacant 
			end


--remove duplicates
with rownumcte as(
select *,
	ROW_NUMBER() over (
	partition by parcelid,
				propertyaddress,
				saledate,
				saleprice,
				legalreference
				order by 
				uniqueid)
				row_number 
from Portfolioproject..housingdata
--order by parcelid 
)
select *
from rownumcte
where row_number>1
order by propertyaddress

--replace the last select with delete and remover orderby statement
with rownumcte as(
select *,
	ROW_NUMBER() over (
	partition by parcelid,
				propertyaddress,
				saledate,
				saleprice,
				legalreference
				order by 
				uniqueid)
				row_number 
from Portfolioproject..housingdata
--order by parcelid 
)
delete
from rownumcte
where row_number> 1




--delete unused column
select *
from Portfolioproject..housingdata

alter table Portfolioproject..housingdata
drop column saleDate,taxdistrict,owneraddress,propertyaddress