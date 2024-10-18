-- Delete Unused Columns

Select *
FROM nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress

ALTER TABLE nashvillehousing
DROP COLUMN SaleDate; 



		

