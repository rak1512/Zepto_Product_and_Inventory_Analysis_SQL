drop table if exists zepto;

create table zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,	
quantity INTEGER
);



select * from Zepto
--data exploration

--count of rows
select count(*) from zepto; --3731

--sample data
SELECT * FROM zepto
LIMIT 10;

--null values
SELECT * 
FROM zepto
WHERE sku_id IS NULL
OR
category IS NULL
OR
name IS NULL
OR
mrp IS NULL
OR
discountpercent IS NULL
OR
availablequantity IS NULL
OR
discountedsellingprice IS NULL
OR
weightingms IS NULL
OR
outofstock IS NULL
OR
quantity IS NULL

--different product categories
SELECT DISTINCT category
FROM zepto

--products in stock vs out of stock
SELECT outofstock, count(sku_id)
FROM zepto
GROUP BY outofstock


--product names present multiple times
SELECT name ,count(sku_id) AS multiple_products
FROM zepto
GROUP BY name
HAVING count(sku_id) > 1
ORDER BY multiple_products DESC

-----data cleaning
--products with price = 0
SELECT * 
FROM zepto
WHERE mrp = 0 
OR discountedsellingprice = 0

DELETE FROM zepto
WHERE mrp = 0

--convert paise to rupees
UPDATE zepto 
SET mrp = mrp/100.0,
discountedsellingprice = discountedsellingprice/100.0


SELECT * FROM zepto;

----data analysis
-- Q1. Find the top 10 best-value products based on the discount percentage.
SELECT sku_id, category,name, mrp, discountpercent
FROM zepto
ORDER BY discountpercent DESC
LIMIT 10;

--Q2.What are the Products with High MRP but Out of Stock
SELECT DISTINCT name, mrp, outofstock
FROM zepto
WHERE outofstock = 'true' 
AND mrp > 300
ORDER BY mrp DESC

--Q3.Calculate Estimated Revenue for each category
SELECT category, sum(discountedsellingprice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC


-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT DISTINCT name,mrp,discountpercent
FROM zepto
WHERE mrp > 500
AND discountpercent < 10
ORDER BY mrp DESC,discountpercent DESC

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT category,ROUND(AVG(discountpercent), 2) AS average_discount
FROM zepto
GROUP BY category
ORDER BY average_discount DESC
LIMIT 5


-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, discountedsellingprice, weightingms,
ROUND(discountedsellingprice/weightingms,2) AS price_per_gm
FROM zepto
WHERE weightingms > 100
ORDER BY price_per_gm DESC

--Q7.Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightingms,
CASE WHEN weightingms <= 1000 THEN 'LOW'
	 WHEN weightingms <= 5000 THEN 'MEDIUM'
	 ELSE 'BULK'
END AS weight_category
FROM zepto
ORDER BY weight_category;

--Q8.What is the Total Inventory Weight Per Category 
SELECT category ,sum(availablequantity * weightingms) AS total_inventory
FROM zepto
GROUP BY category
ORDER BY total_inventory DESC

---Sales / Revenue Analysis
-- Q9. Find top 10 products with highest estimated revenue
SELECT DISTINCT name , (discountedsellingprice * availablequantity) AS total_estimated_revenue
FROM zepto
ORDER BY total_estimated_revenue DESC
LIMIT 10 
-- Q10. Find categories with the highest total available quantity
SELECT category, SUM(availablequantity) AS total_available_quantity
FROM zepto
GROUP BY category
ORDER BY total_available_quantity DESC

-- Q11. Find average MRP and average selling price by category
SELECT category, ROUND(AVG(mrp), 2) AS avg_mrp , ROUND(AVG(discountedsellingprice),2) AS avg_selling_price
FROM zepto
GROUP BY category
ORDER BY avg_mrp DESC

-- Q12. Find products where discount amount is highest
SELECT DISTINCT name , (mrp - discountedSellingPrice) AS discounted_amount
FROM zepto
ORDER BY discounted_amount DESC
LIMIT 10

-- Q13. Find Bottom 5 categories generating lowest estimated revenue
SELECT category, sum(discountedsellingprice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue 
LIMIT 5

---Inventory Analysis
-- Q14. Find products with low stock
-- availableQuantity less than 10
SELECT DISTINCT name, availablequantity
FROM zepto
WHERE availablequantity < 10
ORDER BY availablequantity

-- Q15. Find out-of-stock percentage by category
SELECT 
    category,
    ROUND(
        COUNT(*) FILTER (WHERE outofstock) * 100.0 / COUNT(*),
        2
    ) AS out_of_stock_percentage
FROM zepto
GROUP BY category
ORDER BY out_of_stock_percentage DESC;

-- Q16. Find categories with most out-of-stock products
SELECT 
    category,  
    COUNT(*) AS total_products,
    COUNT(*) FILTER (WHERE outofstock) AS outofstock_products, 
    COUNT(*) FILTER (WHERE NOT outofstock) AS available_products
FROM zepto
GROUP BY category
ORDER BY outofstock_products DESC;


-- Q17. Find heavy products with low available quantity
SELECT DISTINCT name, weightingms, availablequantity
FROM zepto
WHERE availablequantity < 10 AND
weightingms > 5000

-- Q18. Find total inventory value by category
SELECT category , sum(availablequantity * discountedsellingprice) AS inventory_value 
FROM zepto
GROUP BY category
ORDER BY inventory_value DESC

Discount / Pricing Analysis
-- Q19. Find products with discount greater than 50%
SELECT DISTINCT name,discountPercent
FROM zepto
WHERE discountPercent > 50
-- Q20. Compare MRP vs selling price by category
SELECT category, 
	SUM(mrp) AS mrp , 
	SUM(discountedsellingprice) AS discounted_selling_price,
	SUM(mrp) - SUM(discountedSellingPrice) AS total_discount,
    ROUND(
        (SUM(mrp) - SUM(discountedSellingPrice)) * 100.0 / SUM(mrp),2
    ) AS discount_percentag
FROM zepto
GROUP BY category
ORDER BY total_discount DESC
-- Q21. Find products where discountPercent is 0
SELECT DISTINCT name ,discountpercent
FROM zepto
WHERE discountpercent = 0

-- Q22. Find expensive products with high discount
SELECT DISTINCT name, mrp , discountpercent
FROM zepto
WHERE mrp >1500 AND discountpercent > 35;

-- Q23. Find categories where average discount is below 10%
SELECT category , 
	ROUND(AVG(discountpercent),2) AS avg_discount_percent,
	COUNT(*) AS total_products
FROM zepto
GROUP BY category
HAVING AVG(discountpercent) < 10
ORDER BY avg_discount_percent DESC;


Business Insight Questions
-- Q24. Which categories have high inventory but low discount?
SELECT category , sum(availablequantity) AS inventory,
	ROUND(AVG(discountpercent),2) AS discount
FROM zepto
GROUP BY category
HAVING AVG(discountpercent) < 10 AND sum(availablequantity) > 1500
ORDER BY inventory DESC

-- Q26. Which products are overpriced compared to category average?

SELECT 
    category,
    name,
    mrp,
    ROUND(AVG(mrp) OVER (PARTITION BY category), 2) AS category_avg_mrp,
    ROUND(mrp - AVG(mrp) OVER (PARTITION BY category), 2) AS price_above_avg
FROM zepto
WHERE mrp > (
    SELECT AVG(z2.mrp)
    FROM zepto z2
    WHERE z2.category = zepto.category
)
ORDER BY price_above_avg DESC;
