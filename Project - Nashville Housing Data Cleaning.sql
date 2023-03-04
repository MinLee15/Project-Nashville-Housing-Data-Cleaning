--DATA CLEANING IN MICROSOFT SQL

--STANDARDIZE DATE FORMAT
ALTER TABLE Data 
ADD SaleDateConverted DATE;
UPDATE Data
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDate, SaleDateConverted
FROM NashvilleHousing..Data


--POPULATE PROPERTY ADDRESS DATA THAT ARE EMPTY
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing..Data a
JOIN NashvilleHousing..Data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing..Data a
JOIN NashvilleHousing..Data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS, CITY, STATE)
--METHOD 1
SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing..Data


ALTER TABLE Data 
ADD PropertySplitAddress NVARCHAR(255);
UPDATE Data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE Data 
ADD PropertySplitCity NVARCHAR(255);
UPDATE Data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing..Data


--METHOD 2
SELECT 
PARSENAME(REPLACE(OwnerAddress , ',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress , ',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress , ',' , '.'),1)
FROM NashvilleHousing..Data


ALTER TABLE Data 
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE Data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',' , '.'),3)

ALTER TABLE Data 
ADD OwnerSplitCity NVARCHAR(255);
UPDATE Data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',' , '.'),2)

ALTER TABLE Data 
ADD OwnerSplitState NVARCHAR(255);
UPDATE Data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress , ',' , '.'),1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing..Data


--CHANGE Y and N TO YES and NO IN SoldAsVacant COLUMN
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing..Data
GROUP BY SoldAsVacant

UPDATE Data
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing..Data


--CHECK AND REMOVE DUPLICATES
WITH CTE_row_num AS
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID
				 ) AS row_num
FROM NashvilleHousing..Data
)
SELECT DISTINCT (row_num), COUNT(row_num)
FROM CTE_row_num
GROUP BY row_num


WITH CTE_row_num AS
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID
				 ) AS row_num
FROM NashvilleHousing..Data
)
DELETE
FROM CTE_row_num
WHERE row_num > 1


--DELETE UNUSED COLUMNS
ALTER TABLE NashvilleHousing..Data
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate