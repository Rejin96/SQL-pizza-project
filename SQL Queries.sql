-- Retrieve the total number of orders placed.
SELECT COUNT(*) AS total_orders FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(quantity*price),2) AS total FROM order_details 
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
SELECT pizza_types.name,pizzas.price FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id WHERE pizzas.price=
(SELECT MAX(price) FROM pizzas);

SELECT pizza_types.name,pizzas.price FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id 
ORDER BY pizzas.price DESC LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT pizzas.size,COUNT(order_details.order_details_id) AS order_count
FROM pizzas JOIN order_details ON pizzas.pizza_id =
order_details.pizza_id GROUP BY size ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name,SUM(order_details.quantity) AS quantity
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name 
ORDER BY quantity DESC LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, SUM(order_details.quantity) AS quantity FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) AS hour_part,COUNT(order_id) AS hour_count 
FROM orders GROUP BY hour_part ORDER BY hour_part;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category,SUM(quantity) AS distribution FROM pizza_types JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category;

SELECT category,COUNT(pizza_type_id) FROM pizza_types GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(no_of_p_ordered),0) AS average FROM
(SELECT order_date,SUM(quantity) AS no_of_p_ordered FROM orders 
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name, SUM(quantity*pizzas.price) AS revenue FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name ORDER BY revenue DESC LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category, CONCAT(
ROUND(SUM(order_details.quantity * pizzas.price)/(
SELECT ROUND(SUM(quantity*price),2) AS total FROM order_details 
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
) * 100 ,2) , '%')
AS revenue FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.
SELECT orders.order_date, ROUND(SUM(order_details.quantity * pizzas.price),2) AS revenue,
ROUND(SUM(SUM(order_details.quantity * pizzas.price)) 
OVER (ORDER BY orders.order_date),2) AS cumulative
FROM orders Join order_details ON orders.order_id = order_details.order_id
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY orders.order_date
ORDER BY orders.order_date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category,name FROM
(SELECT category,name,revenue ,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn FROM
(SELECT pizza_types.name,pizza_types.category,SUM(order_details.quantity*pizzas.price) 
AS revenue FROM order_details 
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name,pizza_types.category) AS a) AS b
WHERE rn <= 3;


