use sakila;

-- 1a. 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(concat(first_name, ' ', last_name)) as 'Actor Name'
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name 
from actor;
-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor 
where last_name like '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor 
where last_name like '%gen%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country where country IN ('Afghanistan', 'Bangladesh','China'); 
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor add column name_description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor 
drop column name_description;
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*)  as 'Count' from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
select last_name, count(*)  as 'Count' from actor
group by last_name
having count > 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor
set first_name= 'HARPO'
where first_name='GROUCHO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor
set first_name = case when first_name = 'HARPO'
then 'GROUCHO' 
end
where actor_id = 172;
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
describe address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select staff.first_name, staff.last_name, address.address
from staff
inner join address on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select first_name, last_name, sum(amount) -- as total_amount
from staff 
inner join payment
on staff.staff_id = payment.staff_id
where  payment_date between '2005-08-01' and '2005-08-30'
group by payment.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select title, count(actor_id) from film_actor
 inner join film on film.film_id = film_actor.film_id
group by title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, count(title) 
from film
inner join inventory 
on film.film_id = inventory.film_id
where title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select  last_name, first_name, sum(amount) as 'Total Amount Paid' 
 from customer a  join payment b
 
on a.customer_id = b.customer_id
group by last_name, first_name
order by last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title from film where language_id =(select language_id 
                                                                   from language where name ='English')
and (title like 'K%' or title like 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor 
where actor_id in (select actor_id from film_actor 
                              where film_id=(select film_id from film where title ='Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select a.first_name, a.last_name, a.email 
from customer a
inner join address b on a.address_id = b.address_id
inner join city c on b.city_id=c.city_id
inner join country ct on c.country_id = ct.country_id
where country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title from film
where film_id in (select film_id
                            from film_category
                            where category_id =(select category_id from category 
                            where name ='Family'));

-- 7e. Display the most frequently rented movies in descending order.
select a.title, count(rental_id) as 'Rental Frequency'
from rental r join inventory b
on (r.inventory_id = b.inventory_id) 
join film a on(b.film_id = a.film_id)
group by a.title
order by 'Rental Frequency' desc;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
select sum(a.amount) as 'Total Amount in ($)', b.store_id 
from payment a 
inner join rental r on a.rental_id = r.rental_id
inner join staff b on r.staff_id = b.staff_id
inner join  store s on b.store_id = s.store_id
group by b.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, c.city, ct.country
from store s 
inner join  address a on s.address_id=a.address_id
inner join city c on a.city_id=c.city_id
inner join country ct on c.country_id = ct.country_id
group by store_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select name as 'Genres', sum(p.amount) as 'Gross_Revenue'
from category c
join film_category fcat
on c.category_id=fcat.category_id
join inventory i 
on fcat.film_id= i.film_id
join rental r
on i.inventory_id=r.inventory_id
join payment p
on r.rental_id = p.rental_id
group by Genres
order by Gross_Revenue desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view Top_Five_Gross_Genres as
select name as 'Genres', sum(p.amount) as 'Gross_Revenue'
from category c
join film_category fcat
on c.category_id=fcat.category_id
join inventory i 
on fcat.film_id= i.film_id
join rental r
on i.inventory_id=r.inventory_id
join payment p
on r.rental_id = p.rental_id
group by Genres
order by Gross_Revenue desc
limit 5;
-- 8b. How would you display the view that you created in 8a?
select * from Top_Five_Gross_Genres;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view Top_Five_Gross_Genres;

