-- Cleaning data in SQL

SELECT *
FROM NashvilleHousing

-- Converting the SaleDate column from datetime format using ALTER TABLE, UPDATE & CONVERT

SELECT SaleDate, CONVERT(DATE, SALEDATE)
FROM NashvilleHousing

ALTER TABLE NASHVILLEHOUSING
ADD SaleDateConverted date


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SALEDATE)

-- Testing

SELECT SaleDateConverted, CONVERT(DATE, SALEDATE)
FROM NashvilleHousing

-- Fixing nulls in the PropertyAddress column  

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress =  ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-- Writing query to check if the NULLS in ProperyAddress column have been fixed

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NOT NULL

-- Spliting the PropertyAddress column into individual columns ( Address, City) using SUBSTRING, CHARINDEX

--SELECT PropertyAddress 
--FROM NashvilleHousing

SELECT 
SUBSTRING(PROPERTYADDRESS,1, CHARINDEX(',', PROPERTYADDRESS) -1) AS ADDRESS
, SUBSTRING(PROPERTYADDRESS, CHARINDEX(',', PROPERTYADDRESS) +1 , LEN(PROPERTYADDRESS)) AS city
FROM NashvilleHousing

-- Creating new columns

ALTER TABLE NASHVILLEHOUSING
ADD SplitAddress nvarchar(255)


UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PROPERTYADDRESS,1, CHARINDEX(',', PROPERTYADDRESS) -1)

ALTER TABLE NASHVILLEHOUSING
ADD SplitCity varchar(255)


UPDATE NashvilleHousing
SET SplitCity = SUBSTRING(PROPERTYADDRESS, CHARINDEX(',', PROPERTYADDRESS) +1 , LEN(PROPERTYADDRESS))

-- Spliting the OwnerAddress column into individual columns ( Address, City) using PARSENAME

SELECT 
PARSENAME(REPLACE(OWNERADDRESS, ',', '.'), 3)
PARSENAME(REPLACE(OWNERADDRESS, ',', '.'), 2)
PARSENAME(REPLACE(OWNERADDRESS, ',', '.'), 1) 
FROM NashvilleHousing

-- Updating the table with the individual columns

ALTER TABLE NASHVILLEHOUSING
ADD OwnerSplitAddress nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OWNERADDRESS, ',', '.'), 3)

ALTER TABLE NASHVILLEHOUSING
ADD OwnerCity varchar(255)


UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OWNERADDRESS, ',', '.'), 2)

ALTER TABLE NASHVILLEHOUSING
ADD OwnerState varchar(255)


UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OWNERADDRESS, ',', '.'), 1) 

-- Changing the 'Y' and 'N' in the SoldAsVacant Field to 'Yes' and 'No' USING CASE

SELECT DISTINCT (SoldAsVacant), count(soldasvacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE
	WHEN SOLDASVACANT = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SOLDASVACANT = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

-- Removing duplicates using SQL using CTE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER 
	(PARTITION BY ParcelId, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) AS RowNUMBER
	
FROM NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE RowNUMBER > 1


-- DELETING UNUSED COLUMNS 

SELECT *
FROM NashvilleHousing

ALTER  TABLE NASHVILLEHOUSING
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER  TABLE NASHVILLEHOUSING
DROP COLUMN SaleDate