-- HW 05
-- Q1
	SELECT 
		*,
		(SELECT customer_id FROM orders o where od.order_id = o.id) as customer_id
	FROM
		order_details od;

-- Q2
	SELECT
		*
	FROM
		order_details od 
	WHERE
		od.order_id in (SELECT DISTINCT id FROM orders o WHERE o.shipper_id = 3);
	
-- Q3
	SELECT
		*
	FROM
		(SELECT order_id, AVG(quantity) as avg_quantity FROM order_details od WHERE quantity > 10 GROUP BY order_id) a;
	
-- Q4
	WITH temp AS (
		SELECT 
			order_id, 
			AVG(quantity) as avg_quantity 
		FROM 
			order_details od 
		WHERE 
			quantity > 10 
		GROUP BY 
			order_id
	)
	SELECT
		*
	FROM
		temp t;
		
-- Q5
		
	DROP FUNCTION IF EXISTS division_custom;
		
	DELIMITER //
	
	CREATE FUNCTION division_custom(numerator INT, denominator INT)
	RETURNS INT
	DETERMINISTIC
	NO SQL
	BEGIN
		DECLARE final_result INT;
		SET final_result = numerator / denominator;
		RETURN final_result;
	END //
	
	DELIMITER ;
	
	WITH data_collection AS(
		SELECT
			*,
			COALESCE(LAG(quantity) OVER (PARTITION BY order_id ORDER BY id),0) as prev_quantity
		FROM
			order_details od 
	)
	
	SELECT 
		*,
		CASE WHEN prev_quantity > 0 THEN prev_quantity/quantity ELSE 0 END AS div_quantity,
		CASE WHEN prev_quantity > 0 THEN division_custom(prev_quantity, quantity) ELSE 0 END AS div_quantity_custom
	FROM
		data_collection d
        