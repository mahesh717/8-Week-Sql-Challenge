
    -- Case Study #2 Pizza Metrics --


CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners(runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

  select * from customer_orders ;

CREATE TABLE customer_orders (
   order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time DATETIME
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

  
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name VARCHAR(30)
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');



CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings VARCHAR(30)
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');



CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name varchar(30)
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

drop table pizza_toppings;

    -- Data Cleaning --
  
/*The customer_order table has inconsistent data types.  We must first clean the data before answering any questions. 
The exclusions and extras columns contain values that are either 'null' (text), null (data type) or '' (empty).
We will create a temporary table where all forms of null will be transformed to null (data type) */

 Begin TRANSACTION;

  SELECT 
    order_id,
    customer_id,
    pizza_id,
    CASE
        WHEN exclusions = 'null' THEN null
        ELSE exclusions
    END as exclusions,
    CASE
        WHEN extras = 'null' THEN null
        ELSE extras
    END as extras,
    order_time
INTO #new_customer_orders
FROM customer_orders;


  -- Data Cleaning --
  
  /*The runner_order table has inconsistent data types.  We must first clean the data before answering any questions. 
The distance and duration columns have text and numbers.  We will remove the text values and convert to numeric values.
We will convert all 'null' (text) and 'NaN' values in the cancellation column to null (data type).
We will convert the pickup_time (varchar) column to a timestamp data type.*/

SELECT 
    order_id,
    runner_id,
    cast(CASE 
        WHEN pickup_time = 'null' THEN null
        ELSE pickup_time
    END as datetime) as pickup_time,
    cast(CASE 
        WHEN distance = 'null' THEN null
        ELSE TRIM('km' from distance)
    END as float) as distance,
    cast(CASE
        WHEN duration = 'null' THEN null
        ELSE SUBSTRING(duration, 1, 2)
    END as int)as duration,
    CASE
        WHEN cancellation in ('null', '') THEN null
        ELSE cancellation
END as cancellation
INTO #new_runner_orders
FROM runner_orders;

 commit;

  -- Queries --

--1. How many pizzas were ordered?
 select count(order_id) as no_of_orders from #new_customer_orders; 

 -- Insights :
 /*There are 14 pizzas were ordered.*/
  


-- 2. How many unique customer orders were made?
 select count(distinct(order_id)) as customer_orders from #new_customer_orders;

 -- Insights 
 /*There are 10 customer unique customer orders.*/



 -- 3. How many successful orders were delivered by each runner?
select runner_id as runner, count(order_id) as successful_orders 
from #new_runner_orders
where cancellation is null
group by runner_id
order by successful_orders desc;

-- Insights
/*Runner 1 has succesfully delivered 4 pizzas.
Runner 2 has succesfully delivered 3 pizzas.
Runner 3 has succesfully delivered 1 pizza.*/


-- 4. How many of each type of pizza was delivered?
SELECT
	p.pizza_name,
	count(c.order_id) AS n_pizza_type
FROM
	#new_customer_orders AS c
JOIN pizza_names AS p
ON
	p.pizza_id = c.pizza_id
JOIN #new_runner_orders AS r
ON
	c.order_id = r.order_id
WHERE
	cancellation IS NULL
GROUP BY
	p.pizza_name
ORDER BY
	n_pizza_type DESC;

-- Insights
/*There are 9 Meatlovers pizzas were delivered
There are 3 Vegetarian pizzas were delivered*/



-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id as orders, 
sum(
case when pizza_id = 1 then 1 else 0 end  
) as meatlovers,
sum(
case when pizza_id = 2 then 1 else 0 end  
) as vegetarian
from #new_customer_orders
group by customer_id 
order by customer_id;

-- Insights 
/*Customer 101 ordered 2 Meatlovers and 1 Vegetarian pizzas.
Customer 102 ordered 2 Meatlovers and 1 Vegetarian pizzas.
Customer 103 ordered 3 Meatlovers and 1 Vegetarian pizzas.
Customer 104 ordered 3 Meatlovers pizzas.
Customer 105 ordered 1 Vegetarian pizza.*/



-- 6. What was the maximum number of pizzas delivered in a single order?
with cte as (
select count(r.order_id) as orders, count(c.pizza_id) as n_pizzas
from #new_runner_orders as r
inner join #new_customer_orders as c
on r.order_id = c.order_id
where r.cancellation is null
group by r.order_id
)
select max(n_pizzas) as max_orders from cte;

-- Insights 
/*Maximum number of pizzas delivered in a single order is 3 pizzas.*/



-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select c.customer_id as customer,
SUM(case
        when c.exclusions is not null or c.extras is not null then 1 else 0 end       
) as has_change,
SUM(case
        when c.exclusions is null or c.extras is null then 1 else 0 end       
) as no_change
from 
#new_customer_orders as c
inner join
#new_runner_orders as r
on c.order_id = r.order_id
where r.cancellation is null
group by c.customer_id 
order by customer;

-- Insights
/*Customer 101 has 2 changes, whereas 101 also has no changes.
Customer 103, 104, and 105 ordered pizzas with at least 1 change either ordered their pizzas with exclusions or extras. Customer 104 also ordered pizza with no change once.*/



-- 8. How many pizzas were delivered that had both exclusions and extras?
select top 1 (c.order_id) as pizzas from #new_customer_orders as c 
inner join #new_runner_orders as r
on c.order_id = r.order_id
where c.exclusions is not null and c.extras is not null and r.cancellation is null
group by c.order_id
order by c.order_id;

-- Insights
/*There is just one pizza delivered with both exclusions and extras*/



-- 9. What was the total volume of pizzas ordered for each hour of the day?
select DATEPART(HOUR,order_time) as hour_day,
count(order_id) as pizza_orders 
from #new_customer_orders
group by DATEPART(HOUR,order_time);

-- Insights 
/*The highest volume of pizzas ordered at 13.00, 18.00, 21.00, and 23.00
The lowest volume of pizzas ordered at 11.00 and 19.00*/



-- 10. What was the volume of orders for each day of the week?
select format(order_time,'dddd') as week_day,
count(order_id) as total_orders
from #new_customer_orders
group by format(order_time,'dddd');

-- Insights
/*The highest volume of orders on Saturday and Wednesday with 5 pizzas.
There are 3 ordered of pizzas on Thursday.
The lowest volume of orders on Friday with only 1 pizza.*/





       -- Case study  #2 B. Runner and Customer Experience --


-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) ? 
select DATEPART(week,registration_date) as week,
count(runner_id) as runners_signed_up 
from runners 
group by DATEPART(week,registration_date);



-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select r.runner_id,
AVG(DATEDIFF(minute,c.order_time,r.pickup_time)) as avg_time_to_hq
from #new_runner_orders as r
inner join #new_customer_orders as c
on r.order_id = c.order_id
group by r.runner_id ;



-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
with prep_time as (
select count(c.pizza_id) as n_pizzas,
DATEDIFF(MINUTE,c.order_time,r.pickup_time) as order_time_for_pizza,
DATEDIFF(MINUTE,c.order_time,r.pickup_time) / count(c.pizza_id) as time_taken_per_pizza
from #new_customer_orders as c
inner join #new_runner_orders as r
on c.order_id = r.order_id
group by c.pizza_id,c.order_time,r.pickup_time
)
select  
	n_pizzas,
	AVG(order_time_for_pizza) as avg_total_time_taken,
	AVG(time_taken_per_pizza) as avg_time_taken_per_pizza
from prep_time
group by n_pizzas;



-- 4. What was the average distance travelled for each customer?
select * from #new_customer_orders;
select * from #new_runner_orders;

select c.customer_id, round(AVG(r.distance),2) as avg_distance_travelled
from #new_customer_orders as c
inner join #new_runner_orders as r
on c.order_id = r.order_id
group by c.customer_id;



-- 5. What was the difference between the longest and shortest delivery times for all orders?
select 
MAX(duration) as longest_delivery_time,
MIN(duration) as shortest_delivery_time,
MAX(duration) - MIN(duration) as diff_between
from #new_runner_orders ;



-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id,distance,duration,
Round(distance/duration*60,2) as speed_km_hr
from #new_runner_orders
where cancellation is null
order by runner_id,speed_km_hr ;

-- trend for these values I noticed that, the runner get older the faster they go



-- 7. What is the successful delivery percentage for each runner?
select runner_id,
count(order_id) as total_orders,
count(pickup_time) as total_orders_delivered,
cast(count(pickup_time)as float) / cast(count(order_id)as float)*100 as success_delivery_percent
from #new_runner_orders
group by runner_id ;




    -- Case Study #2 C. Ingredient Optimisation --


	  -- Data Cleaning --
  
  /*1. Ingredients Optimizations
  We need to unnested the array of pizza toppings!!!

  we have use strig_split() function to change comma separated 
  ids into multiple rows, then join data with pizza_toppings table to get topping_names*/

begin transaction;
 SELECT		
   p.pizza_id,
   TRIM(t.value) AS topping_id,
   pt.topping_name
 INTO #cleaned_toppings
 FROM 
     pizza_recipes as p
     CROSS APPLY string_split(p.toppings, ',') as t
     JOIN pizza_toppings as pt
     ON TRIM(t.value) = pt.topping_id ;



/*2. Each order contain 1 or many pizzas so it is difficult to select each one seperately for further analysis */
ALTER TABLE #new_customer_orders
ADD record_id INT IDENTITY(1,1);


/*3. Extras and exclusions of each pizza ordered are stored as comma separated string
SQL Transformations: using string_split() sql function to change comma separated ids into multiple rows */

-- to generate extra table
SELECT		
	c.record_id,
	TRIM(e.value) AS topping_id
INTO #extras
FROM 
	#new_customer_orders as c
	CROSS APPLY string_split(c.extras, ',') as e
;

select * from #new_customer_orders;
-- to generate exclusions table
SELECT		
	c.record_id,
	TRIM(e.value) AS topping_id
INTO #exclusions
FROM 
	#new_customer_orders as c
	CROSS APPLY string_split(c.exclusions, ',') as e
;
commit;

	  -- Data Cleaning ENDS--




-- Queries 

-- 1. What are the standard ingredients for each pizza ?
select p.pizza_name,
c.topping_name 
from pizza_names as p
inner join #cleaned_toppings as c
on p.pizza_id = c.pizza_id ;



-- 2. What was the most commonly added extra ?
with cte as (
select 
ct.topping_name,
count(ct.topping_id) as added_extra
from #cleaned_toppings as ct
inner join #extras as e
on ct.topping_id = e.topping_id
group by ct.topping_name 
)
select top 1 topping_name from cte 
group by topping_name;




-- 3. What is the total quantity of each ingredient used in all ordered pizzas sorted by most frequent first ?

/*My explanation & approach:

This question wants to show each topping and the number of times it is used in ordered pizzas including extras & exclusion
I created a CTE to automate the corresponding addition for each ordered pizza topping */

-- Part of Ingredients -- 

select c.order_id as ordered_pizzas, ct.topping_name, count(ct.topping_name) as total_quantity
from #cleaned_toppings as ct
inner join #new_customer_orders as c
on ct.pizza_id = c.pizza_id
group by c.order_id, ct.topping_name
order by total_quantity desc;


-- final result -- 

with cte as (
select c.record_id,ct.topping_name,
case 
-- if extra ingredients then add 2 --
    when ct.topping_id in 
	(select topping_id from #extras as e where e.record_id = c.record_id) then 2
-- if exclude ingredients then add 0 --
    when ct.topping_id in 
	(select topping_id from #exclusions as e where e.record_id = c.record_id) then 0
-- normal ingredients add 1 --
else 1
end as time_used
from 
#cleaned_toppings as ct
inner join #new_customer_orders as c
on c.pizza_id = ct.pizza_id
)
select topping_name, sum(time_used) time_used
from cte
group by topping_name 
order by time_used desc ;




-- 4. What was the most common exclusion ?
with extras_cte as
(
	SELECT 
		record_id,
		'Extra ' + STRING_AGG(t.topping_name, ', ') as record_options
	FROM
		#extras e,
		#cleaned_toppings t
	WHERE e.topping_id = t.topping_id
	GROUP BY record_id
),
exclusions_cte AS
(
	SELECT 
		record_id,
		'Exclude ' + STRING_AGG(t.topping_name, ', ') as record_options
	FROM
		#exclusions e,
		#cleaned_toppings t
	WHERE e.topping_id = t.topping_id
	GROUP BY record_id
),
union_cte AS
(
	SELECT * FROM extras_cte
	UNION
	SELECT * FROM exclusions_cte
)

SELECT 
	c.record_id,
	CONCAT_WS(' - ', p.pizza_name, STRING_AGG(cte.record_options, ' - '))
FROM 
	#new_customer_orders c
	JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
	LEFT JOIN union_cte cte
	ON c.record_id = cte.record_id
GROUP BY
	c.record_id,
	p.pizza_name
ORDER BY 1;




  -- Case Study #2 D.Pricing and Ratings --

  -- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
  --how much money has Pizza Runner made so far if there are no delivery fees ?



 























