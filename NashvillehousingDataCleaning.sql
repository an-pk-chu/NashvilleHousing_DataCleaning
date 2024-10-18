SELECT * FROM nashvillehousing;

--Populate Property Address data
SELECT ParcelID, Propertyaddress
FROM nashvillehousing
--WHERE PropertyAddress is null
order by ParcelID;

-- check unique IDs where their ParcelIDs are simmilar and replace the nulls with the actual address
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nashvillehousing a
JOIN nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null;

UPDATE nashvillehousing a
SET PropertyAddress = b.PropertyAddress
FROM nashvillehousing b
WHERE a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
	AND a.PropertyAddress is null;
	
-- Breaking out Property Address into columns (Address, City)

SELECT PropertyAddress
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD COLUMN StreetAddress VARCHAR(255),
ADD COLUMN City VARCHAR(255);

UPDATE nashvillehousing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) - 1);

UPDATE nashvillehousing
SET City = TRIM(SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 1));

SELECT * FROM nashvillehousing;

-- Breaking our OwnerAddress into colummns (Address, City, State)

FROM nashvillehousing;
ALTER TABLE nashvillehousing
ADD COLUMN owner_street_address VARCHAR(225),
ADD COLUMN owner_city VARCHAR(225),
ADD COLUMN owner_state VARCHAR(225);

UPDATE nashvillehousing
SET owner_street_address = SPLIT_PART(owneraddress,',',1),
 	owner_city = SPLIT_PART(owneraddress,',',2),
	owner_state = SPLIT_PART(owneraddress,',',3);

SELECT owner_street_address, owner_city, owner_sate FROM nashvillehousing;

-- Change Y and N to Yes and No
SELECT SoldAsVacant,
 CASE   WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM nashvillehousing;

UPDATE Nashvillehousing 
SET SoldAsVacant = CASE   WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END;
	
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;

--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
				UniqueID
			)row_num
FROM nashvillehousing)

DELETE FROM nashvillehousing
WHERE UniqueID IN (
	SELECT UniqueID
	From RowNumCTE
	Where row_num > 1)		

-- Delete Unused Columns

Select *
FROM nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress

ALTER TABLE nashvillehousing
DROP COLUMN SaleDate; 




		

