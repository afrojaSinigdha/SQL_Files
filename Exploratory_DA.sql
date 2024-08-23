-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- To see max total_laid_off
SELECT MAX(total_laid_off)
FROM layoffs_staging2;

-- Checking max and min
SELECT MAX(total_laid_off), MIN(total_laid_off)
FROM layoffs_staging2
;

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM layoffs_staging2
;

-- Checking max, min and avg of percentage_laid_off
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off), AVG(percentage_laid_off)
FROM layoffs_staging2
;

-- To see which companies have 100% laid_off
SELECT company, location, percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- To see how big some companies were
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;



-- To see biggest layoff companies
SELECT company, total_laid_off
FROM layoffs_staging2
ORDER BY total_laid_off DESC
LIMIT 10;

-- To see which companies have most layoff
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- By location
SELECT location, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY location
ORDER BY 2 DESC;

-- By stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- By country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- By industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- By date
SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 DESC;

WITH yearly_higgest_companies AS
(
SELECT company,
YEAR(date) AS years, 
SUM(total_laid_off) AS sum_total
FROM layoffs_staging2
GROUP BY company, years
), company_ranking AS
(
SELECT company, 
years, 
sum_total,
DENSE_RANK() OVER(PARTITION BY years ORDER BY sum_total DESC) AS ranking
FROM yearly_higgest_companies
)
SELECT company, 
years, 
sum_total,
ranking
FROM company_ranking
WHERE ranking <= 5
AND years IS NOT NULL
ORDER BY years ASC, sum_total DESC;


WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
