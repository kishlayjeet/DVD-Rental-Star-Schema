-- Creating Table --
create table dimDate
(
	date_key integer 	not null primary key,
	date date 			not null,
	year smallint 		not null,
	quarter smallint 	not null,
	month smallint 		not null,
	day smallint 		not null,
	weak smallint 		not null,
	is_weekend boolean
);

create table dimCustomer
(
	customer_key serial 	primary key,
	customer_id smallint 	not null,
	first_name varchar(45) 	not null,
	last_name varchar(45) 	not null,
	email varchar(50),
	address varchar(50) 	not null,
	address2 varchar(50),
	district varchar(30) 	not null,
	city varchar(30) 		not null,
	country varchar(50) 	not null,
	postal_code varchar(10),
	phone varchar(20) 		not null,
	active smallint 		not null,
	create_date timestamp 	not null,
	start_date date 		not null,
	end_date date 			not null
);

create table dimFilm
(
	film_key Serial 		primary key,
	film_id smallint 		not null,
	title varchar(225) 		not null,
	description text,
	release_year year,
	language varchar(20) 	not null,
	original_language varchar(20),
	rental_duration smallint not null,
	length smallint 		not null,
	rating varchar(5) 		not null,
	special_features varchar(60) not null
);

create table dimStore
(
	store_key Serial 		primary key,
	store_id smallint 		not null,
	address varchar(50) 	not null,
	address2 varchar(50),
	district varchar(20) 	not null,
	city varchar(40) 		not null,
	country varchar(30) 	not null,
	postal_code varchar(10),
	manager_first_name varchar(45) not null,
	manager_last_name varchar(45) not null,
	start_date date 		not null,
	end_date date 			not null
);

-- Inserting Values --
insert into dimDate
(date_key, date, year, quarter, month, day, weak, is_weekend)
select
	distinct(TO_CHAR(payment_date :: date, 'yyyymmdd')::integer) as date_key,
	date(payment_date) 					as date,
	extract(year from payment_date) 	as year,
	extract(quarter from payment_date) 	as quarter,
	extract(month from payment_date) 	as month,
	extract(day from payment_date) 		as day,
	extract(week from payment_date) 	as week,
	case 
		when extract(ISODOW from payment_date) in(6, 7) 
		then true 
		else false 
	end as is_weekend
from payment;

insert into dimCustomer
(customer_key, customer_id, first_name, last_name, email, address, address2, district, city, country, postal_code, phone, active, create_date, start_date, end_date)
select
	c.customer_id 	as customer_key,
	c.customer_id,
	c.first_name,
	c.last_name,
	c.email,
	a.address,
	a.address2,
	a.district,
	ct.city,
	cu.country,
	postal_code,
	a.phone,
	c.active,
	c.create_date,
	now() 			as start_date,
	now() 			as end_date
from customer c
join address a 		on(c.address_id = a.address_id)
join city ct 		on(a.city_id = ct.city_id)
join country cu 	on(ct.country_id = cu.country_id);

insert into dimFilm
(film_key, film_id, title, description, release_year, language, original_language, rental_duration, length, rating, special_features)
select
	f.film_id 		as film_key,
	f.film_id,
	f.title,
	f.description,
	f.release_year,
	l.name 			as language,
	ol.name 		as original_language,
	f.rental_duration,
	f.length,
	f.rating,
	f.special_features
from film as f
join language as l 			on(f.language_id = l.language_id)
left join language as ol 	on(f.language_id = ol.language_id);

insert into dimStore
(store_key, store_id , address, address2, district, city, country, postal_code, manager_first_name, manager_last_name, start_date, end_date)
select
	s.store_id 		as store_key,
	s.store_id,
	a.address,
	a.address2,
	a.district,
	ct.city,
	cu.country,
	a.postal_code,
	st.first_name 	as manager_first_name,
	st.last_name 	as manager_last_name,
	now() 			as start_date,
	now() 			as end_date
from store s
join staff st 		on(s.manager_staff_id = st.staff_id)
join address a 		on(s.address_id = a.address_id)
join city ct 		on(a.city_id = ct.city_id)
join country cu 	on(ct.country_id = cu.country_id);

-- Creating Refrencing Table --
create table factSales
(
	sales_key serial 		primary key,
	date_key integer 		references dimDate(date_key),
	customer_key integer 	references dimCustomer(customer_key),
	film_key integer 		references dimFilm(film_key),
	store_key integer 		references dimStore(store_key),
	sales_amount numeric
);

-- Inserting Values To Refrencing Table --
insert into factSales
(date_key, customer_key, film_key, store_key, sales_amount)
select
	TO_CHAR(payment_date :: date, 'yyyymmdd')::integer as date_key,
	p.customer_id 		as customer_key,
	i.film_id 			as film_key,
	i.store_id 			as store_key,
	p.amount 			as sales_amount
from payment p
join rental as r 	on(p.rental_id = r.rental_id)
join inventory as i on(r.inventory_id = i.inventory_id);

-- Show All The Tables --
select * from dimcustomer;
select * from dimdate;
select * from dimfilm;
select * from dimstore;
select * from factSales;

-- Test Start Schema --
select dimFilm.title, dimDate.month, dimCustomer.city, sum(sales_amount) as revenue
from factSales 
join dimFilm    	on(dimFilm.film_key = factSales.film_key)
join dimDate     	on(dimDate.date_key = factSales.date_key)
join dimCustomer 	on(dimCustomer.customer_key = factSales.customer_key)
group by (dimFilm.title, dimDate.month, dimCustomer.city)
order by dimFilm.title, dimDate.month, dimCustomer.city, revenue desc;


-- Test 3nf Schema --
select f.title, extract(month from p.payment_date) as month, ci.city, sum(p.amount) as revenue
from payment p
join rental r    	on(p.rental_id = r.rental_id)
join inventory i 	on(r.inventory_id = i.inventory_id)
join film f 		on(i.film_id = f.film_id)
join customer c 	on(p.customer_id = c.customer_id)
join address a 		on(c.address_id = a.address_id)
join city ci 		on(a.city_id = ci.city_id)
group by (f.title, month, ci.city)
order by f.title, month, ci.city, revenue desc;












