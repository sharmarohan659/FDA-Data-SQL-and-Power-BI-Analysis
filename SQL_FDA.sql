/*Task 1.1 - Determine the number of drugs approved each year*/

SELECT YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) AS ApprovalYear, 
COUNT(p.ProductNo) AS NumDrugsApp
FROM product p 
JOIN regactiondate rd ON p.ApplNo = rd.ApplNo
WHERE rd.ActionType = 'AP' AND rd.ActionDate IS NOT NULL 
GROUP BY ApprovalYear 
ORDER BY ApprovalYear;


/*Task 1.2 - Identify the top three years that got the highest and lowest approvals, 
in descending and ascending order, respectively.*/

/*Top 3 Highest*/
SELECT ApprovalYear,NumDrugsApp 
FROM (
	SELECT YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) AS ApprovalYear, 
	count(p.ProductNo) AS NumDrugsApp
	FROM product p 
	JOIN regactiondate rd ON p.ApplNo = rd.ApplNo
	WHERE rd.ActionType = 'AP' AND rd.ActionDate IS NOT NULL 
	GROUP BY ApprovalYear 
	ORDER BY ApprovalYear) AS Subq
GROUP BY ApprovalYear 
ORDER BY NumDrugsApp DESC 
LIMIT 3;

/*Top 3 Lowest*/
SELECT ApprovalYear,NumDrugsApp 
FROM (
	SELECT YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) AS ApprovalYear, 
	count(p.ProductNo) AS NumDrugsApp
	FROM product p 
    JOIN regactiondate rd ON p.ApplNo = rd.ApplNo
	WHERE rd.ActionType = 'AP' AND rd.ActionDate IS NOT NULL 
	GROUP BY ApprovalYear 
    ORDER BY ApprovalYear) AS Subq
GROUP BY ApprovalYear 
ORDER BY NumDrugsApp ASC 
LIMIT 3;


/*Task 1.3 - Explore approval trends over the years based on sponsors.*/

SELECT YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) AS ApprovalYear, 
a.SponsorApplicant,count(p.ProductNo) AS NumDrugsApp
FROM application a 
JOIN regactiondate rd ON a.ApplNo = rd.ApplNo
JOIN product p ON a.ApplNo = p.ApplNo
WHERE rd.ActionType = 'AP' AND rd.ActionDate IS NOT NULL
GROUP BY ApprovalYear, a.SponsorApplicant
ORDER BY ApprovalYear, NumdrugsApp DESC;


/*Task 1.4 - Rank sponsors based on the total number of approvals 
they received each year between 1939 and 1960.*/

SELECT ApprovalYear, SponsorApplicant, NumDrugsApp, 
DENSE_RANK() OVER (PARTITION BY ApprovalYear ORDER BY NumDrugsApp DESC) AS AppRank
FROM (
	SELECT YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) 
	AS ApprovalYear, a.SponsorApplicant, count(p.ProductNo) AS NumDrugsApp
	FROM application a 
	JOIN regactiondate rd ON a.ApplNo = rd.ApplNo
	JOIN product p ON a.ApplNo = p.ApplNo
	WHERE rd.ActionType = 'AP' AND rd.ActionDate IS NOT NULL 
	AND YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) BETWEEN 1939 AND 1960
	GROUP BY a.SponsorApplicant, ApprovalYear ) AS RankQuery
ORDER BY ApprovalYear, AppRank;

/*Task 2.1 - Group products based on MarketingStatus.*/

SELECT ProductMktStatus,
	CASE ProductMktStatus
	WHEN 1 THEN 'Marketed'
	WHEN 2 THEN 'Withdrawn'
	WHEN 3 THEN 'Pending'
	WHEN 4 THEN 'Pre-Market'
	ELSE 'Unknown'
	END AS StatusDescription, Count(ProductNo) AS ProdCount FROM product 
GROUP BY ProductMktStatus 
ORDER BY ProdCount DESC;


/*Task 2.1 - Calculate the total number of applications 
for each MarketingStatus year-wise after the year 2010.*/

SELECT ProductMktStatus,
	CASE ProductMktStatus
	WHEN 1 THEN 'Marketed'
	WHEN 2 THEN 'Withdrawn'
	WHEN 3 THEN 'Pending'
	WHEN 4 THEN 'Pre-Market'
	ELSE 'Unknown'
	END AS StatusDescription, Count(ProductNo) AS ProdCount FROM product 
GROUP BY ProductMktStatus ORDER BY ProdCount DESC;


/*Task 2.2 - Calculate the total number of applications for each 
MarketingStatus year-wise after the year 2010*/

SELECT p.ProductMktStatus,
	CASE p.ProductMktStatus
	WHEN 1 THEN 'Marketed'
	WHEN 2 THEN 'Withdrawn'
	WHEN 3 THEN 'Pending'
	WHEN 4 THEN 'Pre-Market'
	ELSE 'Unknown'
	END AS StatusDescription, YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) AS ApprovalYear, 
Count(p.ApplNo) AS AppCount 
FROM product p
JOIN regactiondate rd ON p.ApplNo = rd.ApplNo
WHERE YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) > 2010
GROUP BY ApprovalYear, ProductMktStatus 
ORDER BY ApprovalYear, AppCount DESC;


/*Task 2.3 - Identify the top MarketingStatus with the maximum number of 
applications and analyze its trend over time.*/

WITH TopMktStatus AS (
SELECT ProductMktStatus,
Count(ApplNo) AS AppCount FROM product 
GROUP BY ProductMktStatus 
ORDER BY AppCount DESC 
LIMIT 1)
SELECT YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) AS ApprovalYear,
p.ProductMktStatus, Count(p.ApplNo) AS AppCount 
FROM regactiondate rd 
JOIN product p
ON rd.ApplNo = p.ApplNo
WHERE p.ProductMktStatus = (SELECT ProductMktStatus FROM TopMktStatus) 
AND YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) IS NOT NULL
GROUP BY p.ProductMktStatus, ApprovalYear
ORDER BY ApprovalYear;


/*Task 3.1 - Categorize Products by dosage form and analyze their distribution*/

SELECT Dosage, Count(ProductNo) AS ProdCount 
FROM product 
GROUP BY Dosage 
ORDER BY ProdCount DESC;


/*Task 3.2 - Calculate the total number of approvals for each 
dosage form and identify the most successful forms.*/

SELECT p.Form, COUNT(p.ProductNo) AS ProdCount, a.ActionType
FROM product p 
JOIN application a ON p.ApplNo = a.ApplNo
WHERE a.ActionType = 'AP'
GROUP BY p.Form
ORDER BY ProdCount DESC;


/*Task 3.3 - Investigate yearly trends related to successful forms*/

SELECT YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) AS ApprovalYear, p.Form, 
count(p.ProductNo) AS ProdCount
FROM product p 
JOIN regactiondate rd
ON p.ApplNo = rd.ApplNo
WHERE rd.ActionType = 'AP' AND rd.ActionDate IS NOT NULL
GROUP BY ApprovalYear, p.Form
ORDER BY ApprovalYear, ProdCount DESC;


/*Task 4.1 - Analyze drug approvals based on therapeutic evaluation code (TE_Code)*/

SELECT pt.TECode, Count(p.ProductNo) AS ProdCount
FROM product p 
JOIN product_tecode pt
ON p.ApplNo = pt.ApplNo
GROUP BY pt.TECode
ORDER BY ProdCount DESC;


/*Task 4.2 - Determine the therapeutic evaluation code (TE_Code) 
with the highest number of Approvals in each year*/

SELECT ApprovalYear, TECode, ProdCount 
FROM (
	SELECT YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s')) AS ApprovalYear, 
	pt.TECode, count(p.ProductNo) AS ProdCount, 
	ROW_NUMBER() OVER (PARTITION BY YEAR(str_to_date(rd.ActionDate, '%Y-%m-%d %H:%i:%s'))
	ORDER BY Count(p.ProductNo) DESC) AS Rownum
	FROM regactiondate rd 
	JOIN product_tecode pt
	ON rd.ApplNo = pt.ApplNo
	JOIN product p ON rd.ApplNo = p.ApplNo
	WHERE rd.ActionType = 'AP' 
	GROUP BY ApprovalYear, pt.TECode
	ORDER BY ApprovalYear, ProdCount DESC) AS subq
WHERE Rownum = 1
GROUP BY ApprovalYear, TECode;
