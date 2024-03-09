/* cleaning the data in sql*/

select*
from Portfolio.dbo.NashvilleHousing

--standardize the date format

select SaleDateConverted,CONVERT (Date,SaleDate)
from Portfolio.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT (Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT (Date,SaleDate)

--Population proptery address data

select*
from Portfolio.dbo.NashvilleHousing
where PropertyAddress is null

select*
from Portfolio.dbo.NashvilleHousing
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
from Portfolio.dbo.NashvilleHousing a
JOIN Portfolio.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolio.dbo.NashvilleHousing a
JOIN Portfolio.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking address into individual coloumns (address,city,state)

select PropertyAddress
from Portfolio.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
substring (PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address
,substring (PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN (PropertyAddress)) as Address

from Portfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = substring (PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity =substring (PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN (PropertyAddress)) 

select *
from Portfolio.dbo.NashvilleHousing





select OwnerAddress
from Portfolio.dbo.NashvilleHousing


select 
PARSENAME( REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME( REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME( REPLACE(OwnerAddress, ',','.'),1)
from Portfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = parsename ( REPLACE (OwnerAddress,',','.'),3) 

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select *
from Portfolio.dbo.NashvilleHousing



--Change y and n to yes and no in "sold and vacant"field

select distinct (SoldAsVacant),count (SoldAsVacant)
from Portfolio.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE When SoldAsVacant = 'y' then 'yes'
        When SoldAsVacant ='N'	then 'no'
		Else SoldAsVacant
		End
from Portfolio.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'y' then 'yes'
        When SoldAsVacant ='N'	then 'no'
		Else SoldAsVacant
		End





--Remove Duplicates

with RowNumCTE AS (
select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
                 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				    UniqueID
					) row_num


from Portfolio.dbo.NashvilleHousing
--order by ParcelID
)
Select *
from RowNumCTE
Where row_num > 1
--Order by PropertyAddress


select *
from Portfolio.dbo.NashvilleHousing


--Delete Unused columns


select *
from Portfolio.dbo.NashvilleHousing

ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate