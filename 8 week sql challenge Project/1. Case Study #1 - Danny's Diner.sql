
                                  -- Case Study #1 Danny's Dinner --


CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');




  --  Queries  --


  --1. What is the total amount each customer spent at the restaurant?
  select s.customer_id as customers, sum(m.price) as total_amount
  from menu as m
  inner join sales as s
  on m.product_id = s.product_id
  group by s.customer_id
  order by total_amount desc ;

  -- Insights : 
  /*This is the result of the total amount each customer spent at the restaurant,

Customer A spent $76.
Customer B spent $84.
Customer C spent $36. */




  --2. How many days has each customer visited the restaurant? 
select customer_id as customers, COUNT(distinct order_date) as no_of_days
from sales
group by customer_id 
order by no_of_days desc;

-- Insights : 
/* Customer A visited the restaurant 4 times.
Customer B visited the restaurant 6 times.
Customer C visited the restaurant 2 times. */ 



--3. What was the first item from the menu purchased by each customer?
  with cte as (
  select s.customer_id as customers , m.product_name as first_name ,
  row_number() over(partition by s.customer_id order by s.order_date, s.product_id) as r
  from sales as s
  inner join menu as m
  on s.product_id = m.product_id
  )
  select customers,first_name from cte
  where r = 1;

  -- Insights : 
  /* The first items purchased by Customer A are sushi.
The first items purchased by Customer B is curry.
The first items purchased by Customer C is ramen. */



  --4. What is the most purchased item on the menu and how many times was it purchased by all customers?
  select top 1 m.product_name, count(s.product_id) no_of_time
  from menu as m
  inner join sales as s
  on m.product_id = s.product_id
  group by m.product_name, s.product_id
  order by s.product_id desc;

  -- Insights : 
  /* The most purchased item is ramen which has been purchased 8 times. */



  --5. Which item was the most popular for each customer?
with cte as (
  select s.customer_id as customers, m.product_name as most_popular,
  dense_rank() over(partition by s.customer_id order by count(m.product_name) desc) as order_count
  from sales as s
  inner join menu as m
  on s.product_id = m.product_id 
  group by s.customer_id,m.product_name
  )
  select customers,most_popular,order_count
  from cte
  where order_count = 1;

  -- Insights :
  /* Customer A’s favorite is ramen.
Customer B’s favorites are curry, ramen, and sushi.
Customer C’s favorite is ramen. */
  


  --6. Which item was purchased first by the customer after they became a member?
  with cte as (
  select mem.customer_id as customer, m.product_name as item,
  RANK() over(partition by mem.customer_id order by s.order_date) r
  from menu as m
  inner join sales as s
  on m.product_id = s.product_id
  inner join members as mem
  on s.customer_id = mem.customer_id
  where s.order_date >= mem.join_date
  )
  select customer, item from cte 
  where r = 1;

  -- Insights :
  /* Customer’s A first purchased after became a member was curry.
Customer’s B first purchased after became a member was sushi. */



  --7. Which item was purchased just before the customer became a member?
with cte as (
select mem.customer_id as customer, m.product_name as item,
RANK() over(partition by s.customer_id order by s.order_date desc) r
from sales as s
inner join menu as m
on s.product_id = m.product_id
inner join members as mem
on s.customer_id = mem.customer_id
where s.order_date < mem.join_date
)
select customer, item
from cte
where r = 1;

-- Insights : 
/* Customer A’s purchased items before becoming a member are curry and sushi.
Customer B’s purchased item before became a member is sushi. */



  --8. What is the total items and amount spent for each member before they became a member?
with cte as (
select mem.customer_id as customer, count(m.product_id) as total_item, sum(m.price) as amount_spent
from members as mem
inner join sales as s
on mem.customer_id = s.customer_id
inner join menu as m
on s.product_id = m.product_id
where s.order_date < mem.join_date
group by mem.customer_id
)
select *
from cte
order by customer;


-- Insights : 
/* Customer’s A purchased items were 2 sushi with $25 spent.
Customer’s B purchased items were 3 curry with $40 spent. */



--9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as (
select s.customer_id as customer,
sum(case 
        when m.product_name = 'sushi' then (m.price * 20) 
		else (m.price * 10) 
		end) as customer_points
from members as mem
inner join sales as s
on mem.customer_id = s.customer_id
inner join menu as m
on m.product_id = s.product_id
group by s.customer_id
)
select * from cte;

-- Insights :
/* Customer A got 860 points.
Customer B got 940 points. */




-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
with cte as (
select s.customer_id as customer,
sum(case
        when s.order_date < mem.join_date then 
	case 
	    when m.product_name = 'sushi' then (m.price *20)
		else (m.price *10)
		end
		when (s.order_date > mem.join_date +6) then 
	case 
	    when m.product_name = 'sushi' then (m.price *20)
		else (m.price *10)
		end
		else (m.price *20)
end) as customer_points 
from members as mem
inner join sales as s
on mem.customer_id = s.customer_id
inner join menu as m
on s.product_id = m.product_id
where s.order_date <= '2021-01-31'
group by  s.customer_id
)
select * from cte
order by customer;

-- Insights :
/* Customer A’s point by the end of January is 1370 points
Customer B’s point by the end of January is 700 */


