select*
from NashvilleHousing
order by PropertyAddress

--Standarize Date Format
alter table NashvilleHousing
add SaleDateConverted Date;

update nashvillehousing
set SaleDateConverted = convert(date, SaleDate)

select SaleDateConverted, convert(DATE, SaleDate)
from nashvillehousing

--Populate Property Address data

select *
from NashvilleHousing
where PropertyAddress is null
order by ParcelID

--This query self joins the NashvilleHousing table for rows that have the same parcelID. This is because rows with the same ParcelID 
--have the same Property Address as well. Through this, we can fill the null property addresses with another row's property address that has the same ParcelID

select n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress, isnull(n1.PropertyAddress, n2.PropertyAddress)
from NashvilleHousing n1 join NashvilleHousing n2
	on n1.ParcelID = n2.ParcelID and n1.[UniqueID] <> n2.[UniqueID]


--This statement updates the null columns with
update  n1
set PropertyAddress =  isnull(n1.PropertyAddress, n2.PropertyAddress)
from NashvilleHousing n1 join NashvilleHousing n2
	on n1.ParcelID = n2.ParcelID and n1.[UniqueID] <> n2.[UniqueID]
where n1.PropertyAddress is null


--Breaking out Address into Individual Clauses (Address, City, State)

----------------Property Address Transformation---------------------------------------------------------------------------------------------------------------------------------------------
select PropertyAddress
from NashvilleHousing

select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as fg
from NashvilleHousing

alter table NashvilleHousing
add Property_Street nvarchar(255)

update NashvilleHousing
set Property_Street = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

alter table NashvilleHousing
add Property_city nvarchar(255);

alter table NashvilleHousing
add Property_City nvarchar(255)

update NashvilleHousing
set Property_City = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------Owner Address Transformation---------------------------------------------------------------------------------------------------------------------------------------------

select
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

--street column for owner
alter table NashvilleHousing
add Owner_Street nvarchar(255)
update NashvilleHousing
set Owner_Street = parsename(replace(OwnerAddress, ',', '.'), 3)


--city column for owner
alter table NashvilleHousing
add Owner_City nvarchar(255)
update NashvilleHousing
set Owner_City = parsename(replace(OwnerAddress, ',', '.'), 2)

--state column for owner
alter table NashvilleHousing
add Owner_State nvarchar(255)
update NashvilleHousing
set Owner_State = parsename(replace(OwnerAddress, ',', '.'), 1)




-------------Changing Sold as Vacant Column to strictly Yes or No--------------------------------------------------------------------------------------------
Select distinct SoldAsVacant, count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by count(SoldAsVacant) desc

select SoldAsVacant
, case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
  end
from NashvilleHousing

--backing up data before changing original column
select * into NashVillHousingTwo
from NashvilleHousing

--updating original table
update NashvilleHousing
set SoldAsVacant = 
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
 end

 ------------------------Removing Duplicates and storing in a new table------------------------------------------------------------------------------------------------------------------------

Select* into NashvilleHousingUpdate
from NashvilleHousing
select* from NashvilleHousingUpdate
select* from nashvillehousing
with tcte as (
select*, row_number() over (partition by ParcelID, PropertyAddress, SaleDate, LegalReference, Owner_Street,OwnerName order by uniqueid) RowNum
from NashvilleHousingUpdate
)
delete
from tcte
where RowNum > 1

-----------------Removing unused columns---------------------------------------------------------------------------------------------------------

alter table NashvilleHousingUpdate
drop column PropertyAddress, OwnerAddress, SaleDate

select* from NashvilleHousingUpdate