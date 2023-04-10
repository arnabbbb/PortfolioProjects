/*
Data Cleaning in SQL
*/

------------------------------------------------------

USE portfolio_project2;

SELECT *
FROM NashvilleHousing;


-- Standardizing date format --

UPDATE NashvilleHousing
SET SaleDate =  CONVERT(date, SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted =  CONVERT(date, SaleDate);

SELECT *
FROM NashvilleHousing;


SELECT *
FROM NashvilleHousing


-- Populate property address data

SELECT PropertyAddress
FROM NashvilleHousing 
WHERE PropertyAddress IS NULL;

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

-- Filling property address when it's NULL.

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

UPDATE A
SET PropertyAddress =ISNULL(A.propertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ];


-- Breaking Address into multiple columns 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress));

SELECT PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing;

-- Breaking owner address into multiple columns

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing;

-- Change 'Y' and 'N' to 'Yes' and 'No' in 'Sold as vacant' field.

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant;

SELECT 
CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-- Remove Duplicates

WITH CTE AS(
SELECT *,
ROW_NUMBER() 
OVER(
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) row_num
FROM NashvilleHousing
)
DELETE 
FROM CTE
WHERE row_num > 1;

-- Deleting unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

SELECT *
FROM NashvilleHousing;