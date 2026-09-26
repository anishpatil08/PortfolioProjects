--cleaning data in SQL Queries

SELECT *
from PortfolioProject.dbo.NashvileHousing

--Standardize Date Format
select SaleDateCoverted
from PortfolioProject.dbo.NashvileHousing

update NashvileHousing
set SaleDate = convert(date,saledate)

alter table NashvileHousing
add SaleDateCoverted date;

update NashvileHousing
set SaleDateCoverted= convert(date,SaleDate)

------------------------------------------------------------


--populate Property adress

SELECT a.ParcelID ,a.PropertyAddress,b.ParcelID ,b.PropertyAddress,isNULL(a.PropertyAddress , b.PropertyAddress)
from PortfolioProject.dbo.NashvileHousing a
join PortfolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress  is null

update a
SET PropertyAddress =ISNULL(a.PropertyAddress , b.PropertyAddress)
from PortfolioProject.dbo.NashvileHousing a
join PortfolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress  is null

--------------------------------
 --Breaking out adress into individual columns(Address,city,state)

 SELECT PropertyAddress
from PortfolioProject.dbo.NashvileHousing

SELECT 
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1  ) as Address,
Substring(PropertyAddress,CHARINDEX(',',PropertyAddress) +1  ,LEN (PropertyAddress)) as City

from PortfolioProject.dbo.NashvileHousing

--create new column adress and city then add seprated adddresses

ALTER TABLE PortfolioProject.dbo.NashvileHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvileHousing
SET PropertySplitAddress= Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1  )



ALTER TABLE PortfolioProject.dbo.NashvileHousing
ADD PropertySplitCity nvarchar(255);


UPDATE NashvileHousing
SET PropertySplitCity= Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) + 1  )

select *
from PortfolioProject.dbo.NashvileHousing

------------------------------------------------------------
 --OWNER ADDRESS
 select OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
 from  PortfolioProject.dbo.NashvileHousing

select
  PARSENAME(REPLACE(OwnerAddress,',','.'),3) , 
  PARSENAME(REPLACE(OwnerAddress,',','.'),2) , 
  PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
from PortfolioProject.dbo.NashvileHousing

--add two col and put value 

--address
ALTER TABLE PortfolioProject.dbo.NashvileHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvileHousing
SET OwnerSplitAddress=  PARSENAME(REPLACE(OwnerAddress,',','.'),3)


--city
ALTER TABLE PortfolioProject.dbo.NashvileHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvileHousing
SET OwnerSplitCity=  PARSENAME(REPLACE(OwnerAddress,',','.'),2)

--state

ALTER TABLE PortfolioProject.dbo.NashvileHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvileHousing
SET OwnerSplitState=  PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT *
from PortfolioProject.dbo.NashvileHousing

-------------------------------------------------------------------------------------------

--Change Y and N to yes and no in "sold as vacant " field

select distinct(soldasvacant),count(SoldAsVacant)
from PortfolioProject.dbo.NashvileHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE WHEN  SoldAsVacant = 'Y' then  'Yes' 
	 WHEN  SoldAsVacant = 'N' then  'No'  
	 ELSE SoldAsVacant
	 END 
from PortfolioProject.dbo.NashvileHousing

update NashvileHousing
set SoldAsVacant=CASE WHEN  SoldAsVacant = 'Y' then  'Yes' 
	 WHEN  SoldAsVacant = 'N' then  'No'  
	 ELSE SoldAsVacant
	 END 


-----------------------------------------------------------
-- remove duplicates
with RowNumCTE AS (
select * ,
ROW_NUMBER() over (
 PARTITION BY ParcelID,
		      propertyaddress,
			  SalePrice,
			  Saledate,
			  LegalReference
			  Order by 
			  UniqueId
			  ) row_num

from PortfolioProject.dbo.NashvileHousing
--order by ParcelID

)

select * 
from RowNUMCTE 
where row_num> 1
--Order by propertyaddress

----------------------------------------------------
--delete unused columns

select * 
from PortfolioProject.dbo.NashvileHousing

ALTER TABLE PortfolioProject.dbo.NashvileHousing
DROP COLUMN OwnerAddress , TaxDistrict ,PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvileHousing
DROP COLUMN SaleDate
