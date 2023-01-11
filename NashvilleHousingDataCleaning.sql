------------STANDARDIZE DATE FORMAT	-------------------------------
---------------------Method 1

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(DATE,SaleDate)

SELECT SaleDate , CONVERT(DATE,SaleDate)
FROM Training2.dbo.NashvilleHousingData

---------------------Method 2

ALTER TABLE NashvilleHousingData 
ADD SaleDateConverted DATE;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDate , SaleDateConverted
FROM Training2.dbo.NashvilleHousingData

----------------------POPULATE PROPERTY ADDRESS DATA-----------------------

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Training2..NashvilleHousingData a
JOIN Training2..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Training2..NashvilleHousingData a
JOIN Training2..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

SELECT *
FROM Training2.dbo.NashvilleHousingData
WHERE PropertyAddress IS NULL

-----------BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS, CITY, STATE)-----------------------
---------------------Method 1

SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Training2..NashvilleHousingData


ALTER TABLE NashvilleHousingData 
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousingData 
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM Training2.dbo.NashvilleHousingData

---------------------Method 2

SELECT 
PARSENAME(REPLACE(OwnerAddress , ',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress , ',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress , ',' , '.'),1)
FROM Training2..NashvilleHousingData


ALTER TABLE NashvilleHousingData 
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',' , '.'),3)

ALTER TABLE NashvilleHousingData 
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',' , '.'),2)

ALTER TABLE NashvilleHousingData 
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress , ',' , '.'),1)

SELECT *
FROM Training2.dbo.NashvilleHousingData

-----------CHANGE Y and N TO YES and NO IN SoldAsVacant COLUMN-----------------------

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Training2.dbo.NashvilleHousingData
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM Training2.dbo.NashvilleHousingData


UPDATE NashvilleHousingData
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM Training2.dbo.NashvilleHousingData

-----------REMOVE DUPLICATES-----------------------

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
FROM Training2.dbo.NashvilleHousingData
)

DELETE
FROM CTE_row_num
WHERE row_num > 1


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
FROM Training2.dbo.NashvilleHousingData
)

SELECT *
FROM CTE_row_num
WHERE row_num > 1

---------------DELETE UNUSED COLUMNS----------------------
 
 ALTER TABLE Training2.dbo.NashvilleHousingData
 DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

 ALTER TABLE Training2.dbo.NashvilleHousingData
 DROP COLUMN SaleDate



 SELECT *
 FROM Training2.dbo.NashvilleHousingData