-- Create Table From Raw Table

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;


SELECT *
FROM layoffs_staging; 

-- ---------- Delete Duplicate -------------------------------

CREATE TABLE layoffs_staging2 AS
(
	SELECT *,
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
    total_laid_off, percentage_laid_off, 'date', stage, country, 
    funds_raised_millions) AS row_num
	FROM layoffs_staging
);

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE row_num >= 2;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'casper%';

DELETE
FROM layoffs_staging2
WHERE row_num >= 2;

-- --------------- Standardize data ----------------- 

SELECT *
FROM layoffs_staging2;

-- -------- COMPANY --------
UPDATE layoffs_staging2
SET company = TRIM(company);

-- --------- INDUSTRY -------------
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- ---- COUNTRY ------------
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- ------DATE ----
SELECT `date`
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- ------- Populated null industry -------
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- -------- Remove null value from both total 
-- and percentage laid_off columns --------
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- ---- drop the row_num column ----
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
