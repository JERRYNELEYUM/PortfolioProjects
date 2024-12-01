/*

Cleaning Data in SQL Queries

*/

select *
from PortfolioProject.dbo.NashvilleHousingProject


-- Standardize Date Format

select SaleDate
from PortfolioProject.dbo.NashvilleHousingProject


Update NashvilleHousingProject
SET SaleDate = CONVERT(Date,SaleDate)


--If it Doesn't Update properly

ALTER TABLE NashvilleHousingProject
Add SaleDateConverted Date;

Update NashvilleHousingProject
SET SaleDateConverted = CONVERT(Date,SaleDate)


select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousingProject


--Populate Property Address Data


select *
from PortfolioProject.dbo.NashvilleHousingProject
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousingProject a
JOIN PortfolioProject.dbo.NashvilleHousingProject b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousingProject a
JOIN PortfolioProject.dbo.NashvilleHousingProject b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousingProject
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

from PortfolioProject.dbo.NashvilleHousingProject

ALTER TABLE NashvilleHousingProject
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousingProject
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousingProject
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousingProject
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


select *
from PortfolioProject.dbo.NashvilleHousingProject


select OwnerAddress
from PortfolioProject.dbo.NashvilleHousingProject

select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from PortfolioProject.dbo.NashvilleHousingProject

ALTER TABLE NashvilleHousingProject
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousingProject
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousingProject
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousingProject
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousingProject
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousingProject
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



select *
from PortfolioProject.dbo.NashvilleHousingProject


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousingProject
GROUP BY SoldAsVacant
Order by 2


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
	   END
from PortfolioProject.dbo.NashvilleHousingProject

UPDATE NashvilleHousingProject
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
	   END


-- Remove Duplicates

Select *, 
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
				    UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousingProject


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousingProject
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


select *
from PortfolioProject.dbo.NashvilleHousingProject



-- Delete Unused Columns


select *
from PortfolioProject.dbo.NashvilleHousingProject

ALTER TABLE PortfolioProject.dbo.NashvilleHousingProject
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate, TaxDistrict


select *
from PortfolioProject.dbo.NashvilleHousingProject





