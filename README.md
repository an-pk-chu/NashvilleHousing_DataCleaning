
# Nashville Housing Data Cleaning and Transformation

This project is focused on cleaning and transforming a dataset (`nashvillehousing`) to ensure consistency, accuracy, and improved readability for future analysis. The dataset contains real estate information, including property details, sale prices, and ownership details. This README file documents the steps taken to clean the dataset and describes the SQL queries used to manipulate the data.

## Table of Contents

- [Project Overview](#project-overview)
- [Dataset](#dataset)
- [SQL Queries](#sql-queries)
  - [Populate Property Address](#populate-property-address)
  - [Break Property Address into Columns](#break-property-address-into-columns)
  - [Break Owner Address into Columns](#break-owner-address-into-columns)
  - [Standardize SoldAsVacant Values](#standardize-soldasvacant-values)
  - [Remove Duplicates](#remove-duplicates)
  - [Delete Unused Columns](#delete-unused-columns)
- [Usage](#usage)
- [License](#license)

## Project Overview

The purpose of this project is to clean the Nashville housing dataset by:
1. Populating missing property addresses.
2. Breaking down property and owner addresses into separate components (e.g., street, city, state).
3. Standardizing boolean fields like `SoldAsVacant`.
4. Removing duplicate records.
5. Deleting unused columns.

The SQL queries provided aim to improve the structure and usability of the data for future analysis.

## Dataset

The dataset used for this project is `nashvillehousing`, which contains fields such as:
- `ParcelID`
- `PropertyAddress`
- `SalePrice`
- `SaleDate`
- `LegalReference`
- `OwnerAddress`
- `SoldAsVacant`
- And more...

## SQL Queries

### Populate Property Address

This query identifies records with missing property addresses and updates them using matching `ParcelID` values where addresses are available.

```sql
UPDATE nashvillehousing a
SET PropertyAddress = b.PropertyAddress
FROM nashvillehousing b
WHERE a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  AND a.PropertyAddress IS NULL;
```

### Break Property Address into Columns

Here, the `PropertyAddress` field is split into `StreetAddress` and `City` columns for easier querying.

```sql
ALTER TABLE nashvillehousing
ADD COLUMN StreetAddress VARCHAR(255),
ADD COLUMN City VARCHAR(255);

UPDATE nashvillehousing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) - 1),
    City = TRIM(SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 1));
```

### Break Owner Address into Columns

The `OwnerAddress` field is also split into `owner_street_address`, `owner_city`, and `owner_state` columns.

```sql
ALTER TABLE nashvillehousing
ADD COLUMN owner_street_address VARCHAR(225),
ADD COLUMN owner_city VARCHAR(225),
ADD COLUMN owner_state VARCHAR(225);

UPDATE nashvillehousing
SET owner_street_address = SPLIT_PART(owneraddress, ',', 1),
    owner_city = SPLIT_PART(owneraddress, ',', 2),
    owner_state = SPLIT_PART(owneraddress, ',', 3);
```

### Standardize SoldAsVacant Values

The `SoldAsVacant` column values are standardized by converting 'Y' to 'Yes' and 'N' to 'No'.

```sql
UPDATE nashvillehousing
SET SoldAsVacant = CASE
  WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
END;
```

### Remove Duplicates

This query identifies and deletes duplicate rows based on multiple fields (`ParcelID`, `PropertyAddress`, etc.), while retaining only one unique record.

```sql
WITH RowNumCTE AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
  FROM nashvillehousing
)
DELETE FROM nashvillehousing
WHERE UniqueID IN (
  SELECT UniqueID
  FROM RowNumCTE
  WHERE row_num > 1
);
```

### Delete Unused Columns

Finally, columns that are no longer needed, such as `OwnerAddress`, `TaxDistrict`, and `SaleDate`, are removed from the dataset.

```sql
ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, SaleDate;
```

## Usage

To run this project, simply execute the provided SQL queries in sequence on your PostgreSQL database containing the `nashvillehousing` dataset. The queries will transform and clean the data as described.

1. Load the dataset into your PostgreSQL database.
2. Run each SQL query to clean and transform the data.
3. Use the final cleaned dataset for analysis or reporting purposes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
