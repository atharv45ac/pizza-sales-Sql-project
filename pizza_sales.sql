-- create a database
CREATE DATABASE pizzahut;


-- create a new table and import the data from csv.
-- Because there is no option for time data type.
CREATE TABLE orders(
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time time not null,
primary key(order_id));

CREATE TABLE orders_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));


-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price)) AS total_revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;


-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(orders_details.quantity) AS total_quantity
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY total_quantity DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    COUNT(orders_details.quantity) AS quantities_1
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantities_1 DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    COUNT(orders_details.quantity) AS quantities_1
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantities_1 DESC;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
WITH order_quantity AS(
SELECT orders.order_date AS date_1,SUM(orders_details.quantity) AS avg_quantity
FROM orders
JOIN orders_details
ON orders.order_id=orders_details.order_id
GROUP BY date_1)
SELECT ROUND(AVG(avg_quantity))
FROM order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
ROUND(SUM(orders_details.quantity*pizzas.price)/(SELECT ROUND(SUM(orders_details.quantity*pizzas.price))
FROM pizzas
JOIN orders_details
ON orders_details.pizza_id=pizzas.pizza_id)*100,2) AS revenue

FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id=pizzas.pizza_id
GROUP BY pizza_types.category;


-- Analyze the cumulative revenue generated over time.
SELECT order_date,SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM
(SELECT orders.order_date,SUM(orders_details.quantity*pizzas.price) AS revenue
FROM orders_details
JOIN pizzas
ON orders_details.pizza_id=pizzas.pizza_id
JOIN orders
ON orders.order_id=orders_details.order_id
GROUP BY orders.order_date) AS sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category,name,revenue
FROM
	(SELECT category,name,revenue,
	RANK() OVER(partition by category ORDER BY revenue DESC) AS rn
	FROM
		(SELECT pizza_types.category,pizza_types.name,SUM(orders_details.quantity*pizzas.price) AS revenue
		FROM orders_details
			JOIN pizzas
			ON orders_details.pizza_id=pizzas.pizza_id
			JOIN pizza_types
			ON pizza_types.pizza_type_id=pizzas.pizza_type_id
			GROUP BY pizza_types.name,pizza_types.category) AS a) AS b
WHERE rn<=3;
