--Looking at the entire dataset
Select *
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing

--To re-format date column
Select 
	SaleDate
	,CONVERT(Date, SaleDate)
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing

--Doesn't work properly 
Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--So alter the table by adding a new column first
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

--Then fill-in the column with the converted date format
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--To look at Property Address column
Select 
	*
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--Check whether can populate null value
Select
	na1.UniqueID
	,na1.ParcelID
	,na1.PropertyAddress
	,na2.ParcelID
	,na2.PropertyAddress
	,ISNULL(na1.PropertyAddress, na2.PropertyAddress)
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing na1
JOIN ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing na2
	on na1.ParcelID = na2.ParcelID
	AND na1.[UniqueID] <> na2.[UniqueID]
Where na1.PropertyAddress is null

--Update and populate column with Property Address
Update na1
SET PropertyAddress = ISNULL(na1.PropertyAddress, na2.PropertyAddress)
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing na1
JOIN ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing na2
	on na1.ParcelID = na2.ParcelID
	AND na1.[UniqueID] <> na2.[UniqueID]

--Breaking out Addresss into Individual Column (Address, City, State)
Select 
	PropertyAddress
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing

--To split and test using Substring
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing

--Add & Updated Address
ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--Add & Updated City
ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select * From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing

--Looking at Owner Address
Select 
	OwnerAddress 
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing

--Can use Parsename as a delimiter than substring
--But parsename only split fullstop, so have to replace comma with fullstop
--And Parsename do things backward
Select 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing

--Add & Updated Address
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--Add & Updated City
ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--Add & Updated State
ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--To update Y & N to Yes or No
Select Distinct
	SoldAsVacant
	,COUNT(SoldAsVacant)
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select
	SoldAsVacant
	,CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END

--Remove Duplicates with CTE
--BUT DON'T DO TO RAWDATA
--Create Temp table for analysis purpose
WITH RowNumCTE AS (
Select 
	*
	,ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID
		) AS row_num
From ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress

ALTER TABLE ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE ATA_HousingDataCleaningProject_Apr2023..NashvilleHousing
DROP COLUMN SaleDate





