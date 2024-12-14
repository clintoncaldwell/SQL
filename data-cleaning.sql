/* Data Cleaning
 	1. Remove Duplicates
	2. Standardize the Data
	3. Null Values or Blank Values
	4. Remove Any Columns or Rows
*/

-- Copy 'layoffs' data to 'layoffs_staging' for cleaning, while keeping raw data protected
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * 
FROM layoffs;


	-- 1. Remove Duplicates

-- Label Duplicates
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Select Duplicates
WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
) 
SELECT *
FROM duplicate_cte
WHERE row_num >1;

-- Create copy of table to filter out duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Delete Duplicates
DELETE  
FROM layoffs_staging2
WHERE row_num > 1;


	-- 2. Standardizing Data

-- Trim off the whitespace around the values
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Merge similar groups into one
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert Date format from string to date
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


	-- 3. Null Values or Blank Values

-- check for other entries with the same company to fill in missing industry data
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


	-- 4. Remove Any Columns or Rows

-- Remove rows that have no data in both the total and percentage laid off columns
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete column made earlier in step 1
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * FROM layoffs;