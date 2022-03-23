-- Portfolio Project 3: DATA CLEANING --

-- CREATE TABLE --
CREATE TABLE `nt`.`housing` (
`UniqueID` INT NULL,
`ParcelID` VARCHAR(1000) NULL,
`LandUse` VARCHAR(1000) NULL,
`PropertyAddress` VARCHAR(1000) NULL,
`SaleDate` DATE NULL,
`SalePrice`	INT NULL,
`LegalReference` VARCHAR(45) NULL,
`SoldAsVacant` VARCHAR(5) NULL,
`OwnerName`	VARCHAR(1000) NULL,
`OwnerAddress` VARCHAR(1000) NULL,
`Acreage` FLOAT(10,4) NULL,
`TaxDistrict` VARCHAR(500) NULL,
`LandValue`	INT NULL,
`BuildingValue` INT NULL,
`TotalValue` INT NULL,
`YearBuilt`	SMALLINT NULL,
`Bedrooms`	SMALLINT NULL,
`FullBath`	SMALLINT NULL,
`HalfBath` SMALLINT NULL
);

-- SETTINGS --
set global local_infile = 1;
show global variables like 'local_infile';
show variables like 'secure_file_priv';

-- LOAD DATA --
LOAD DATA LOCAL INFILE '/Users/matty/Downloads/Data Analyst Portfolio Project/Project 3 - SQL Data Cleaning/Nashville Housing Data for Data Cleaning.csv'
INTO TABLE nt.housing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
-- SET SaleDate = STR_TO_DATE(@SaleDate, '%m/%d/%Y');
