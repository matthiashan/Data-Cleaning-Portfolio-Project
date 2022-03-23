-- Portfolio Project 3: DATA CLEANING --

SELECT *
FROM nt.housing;


-- Standardize SaleDate Format --

SELECT SaleDate, CONVERT(SaleDate, date)
FROM nt.housing;

UPDATE nt.housing
SET SaleDate = CONVERT(SaleDate, date); 

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data --
SELECT *
FROM nt.housing
WHERE PropertyAddress Is NULL; -- We see that there are some property addresses missing

SELECT *
FROM nt.housing
ORDER BY ParcelID; -- Checking the data, we noticed that the ParcelIDs are linked to their respective Property Addresses

-- We can take the parcelIDs that have matching PropertyAddress and enter them into the missing fields under the PropertyAddress column.
-- Complete a self-join where the property address in table A is null so we can add the correct property address from table b.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nt.housing AS a
JOIN nt.housing AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Use the IFNULL statement to find the NULL values in the a.PropertyAddress column and replace it with the Address in b.PropertyAddress column
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) AS Replacement
FROM nt.housing AS a
JOIN nt.housing AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Update the table
UPDATE 
	nt.housing AS a
JOIN nt.housing AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Doublecheck to see if the changes were made and updated
SELECT PropertyAddress
FROM nt.housing
WHERE PropertyAddress IS NULL;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Separate the address into individual columns (Address, City, State) from the PropertyAddress and OwnerAddress columns --
SELECT PropertyAddress
FROM nt.housing;

-- We can use the SUBSTRING statement that will allow us to extract the string that we want.  
-- The LOCATE allows us to stop at a certain character or number of characters.  In this case we want to pass the ',' in PropertyAddress and we write -1 so that we don't include it
SELECT
	substring(PropertyAddress, 1, locate(',', PropertyAddress) -1 ) AS Address
FROM nt.housing;

-- Building on this, we can use the same statements as above to get the city.  We write +1 because we want to locate the next string passed the ',' from the above query.
SELECT
	substring(PropertyAddress, locate(',', PropertyAddress) +1 ) AS City
FROM nt.housing;

-- We need to alter the table and add new columns that will contain these two newly created fields.
ALTER TABLE nt.housing
ADD Address NVARCHAR(255);
UPDATE nt.housing
SET Address = substring(PropertyAddress, 1, locate(',', PropertyAddress) -1 );

ALTER TABLE nt.housing
ADD City NVARCHAR(255);
UPDATE nt.housing
SET City = substring(PropertyAddress, locate(',', PropertyAddress) +1 );

-- Doublecheck the new table
SELECT *
FROM nt.housing;



-- We can use substring_index for the OwnerAddress column.
SELECT OwnerAddress,
substring_index(OwnerAddress, ',', 1) AS Address, -- Takes the first substring from the left (i.e. the number 1)
substring_index(OwnerAddress, ',', -1) AS State, -- Takes the first substring from the right (i.e. the number -1)
substring_index(substring_index(OwnerAddress,',', 2), ',', -1) AS City
-- Since the state is in the middle, we take the substring within to get the Address and State (i.e. the number 2 represents the second ',' from the left and removes everything after
-- and then takes out the everything from the ',' to the right (i.e. -1)
FROM nt.housing;

-- Now we update the table as we did with the Property Address to include the State
ALTER TABLE nt.housing
ADD State NVARCHAR(255);

UPDATE nt.housing
SET State = substring_index(OwnerAddress, ',', -1);

-- Doublecheck the new table
SELECT *
FROM nt.housing;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nt.housing
GROUP BY 1
ORDER BY 2;

SELECT 
SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
     ELSE SoldAsVacant
END AS SoldAsVacantProper
FROM nt.housing;

UPDATE nt.housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
				   END;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates --


-- We will partition by selecting different columns of which if there are any duplicates, SQL can check against them and remove the ones that are duplicated.  
-- We will take the resulting query into a CTE so we can always reference it.

WITH rownumCTE AS (
SELECT *,
		ROW_NUMBER() OVER( 
							PARTITION BY ParcelID,
										 PropertyAddress,
                                         SalePrice,
                                         SaleDate,
                                         LegalReference
							ORDER BY UniqueID
                            ) ROW_NUM
FROM nt.housing
ORDER BY ParcelID
)

SELECT *
FROM rownumCTE;

/*DELETE
FROM rownumCTE
WHERE ROW_NUM > 1;  

Now we can use the WHERE clause to find the ROW_NUM that have more than 1 result (i.e. are duplicates).  
This doesn't work because you cannot update/delete/insert from a CTE or a view in mySQL.  It doesn't exist in the database.  So we have to create another table (below) and then
delete the duplicates from that table. */

CREATE TABLE nt.housingclean AS
SELECT *,
		ROW_NUMBER() OVER( 
							PARTITION BY ParcelID,
										 PropertyAddress,
                                         SalePrice,
                                         SaleDate,
                                         LegalReference
							ORDER BY UniqueID
                            ) ROW_NUM
FROM nt.housing
ORDER BY ParcelID;

SELECT *
FROM nt.housingclean
WHERE ROW_NUM > 1;

DELETE FROM nt.housingclean
WHERE ROW_NUM >1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns --


ALTER TABLE nt.housingclean
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict,
DROP COLUMN SaleDate,
DROP COLUMN PropertyAddress;

SELECT *
FROM nt.housingclean;



