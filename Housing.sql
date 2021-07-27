-- Viewing The Data
Select *
From PortfolioProject..Housing$

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..Housing$

ALTER TABLE Housing$
Add SaleDateConverted Date;

Update Housing$
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDate, SaleDateConverted
From PortfolioProject..Housing$



--- Fill the NULL Address Values by Using the Parcel and Unique IDs

Select *
From PortfolioProject..Housing$
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..Housing$ a
JOIN PortfolioProject..Housing$ b
on a.ParcelID = b.ParcelID AND  a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
 
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..Housing$ a
JOIN PortfolioProject..Housing$ b
on a.ParcelID = b.ParcelID AND  a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking the address into seperate field (Address, City, State)

Select PropertyAddress
From PortfolioProject..Housing$

--Splitting it using Substring and Charindex (Long Way)

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
From PortfolioProject..Housing$


ALTER TABLE Housing$
Add PropertySplitAddress Nvarchar(255);

Update Housing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE Housing$
Add PropertySplitCity Nvarchar(255);

Update Housing$
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 


Select *
From PortfolioProject..Housing$



Select OwnerAddress
From PortfolioProject..Housing$

-- Splitting it using PARSENAME and Replace (Shortcut)

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject..Housing$


ALTER TABLE Housing$
Add OwnerSplitAddress Nvarchar(255);

Update Housing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE Housing$
Add OwnerSplitCity Nvarchar(255);

Update Housing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE Housing$
Add OwnerSplitState Nvarchar(255);

Update Housing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProject..Housing$


-- Change Y & N to Yes & No

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..Housing$
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From PortfolioProject..Housing$

Update Housing$
Set SoldAsVacant =  CASE when SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END



-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY  ParcelID,
			  PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY 
				UniqueID
				) row_num


From PortfolioProject..Housing$
)

DELETE
From RowNumCTE
where row_num > 1



--- Delete Unused Columns

Select *
From PortfolioProject..Housing$

ALTER TABLE Housing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE Housing$
DROP COLUMN SaleDate