----Count of books by category
select count(distinct id), categories from books_1
group by categories;

select * from books_1;

select count(distinct id) from books_1;----240

select count(distinct id) from books_1;----

---------------------------------------------------------------
---------------------------------------------------------------

select * from checkouts;

select count(distinct BOOKS_ID) from checkouts;---240

select count(BOOKS_ID) from checkouts;---2000

CREATE TABLE BK_DURATION AS
select DISTINCT CUSTOMERS_ID, BOOKS_ID, LIBRARY_ID, DATE_CHECKOUT, DATE_RETURNED, to_char(DATE_RETURNED - DATE_CHECKOUT) DURATION from checkouts
WHERE to_char(DATE_RETURNED - DATE_CHECKOUT) >= 1 AND to_char(DATE_RETURNED - DATE_CHECKOUT) < 1000;

select count(DISTINCT CUSTOMERS_ID), PRICE, PAGES, DATE_CHECKOUT, BIRTH_DATE, to_char(DATE_CHECKOUT- BIRTH_DATE) Age from books_1 a, BK_DURATION b, customers c
where a.id = b.books_id and b.customers_id = c.id
group by PRICE, PAGES, DATE_CHECKOUT, BIRTH_DATE, to_char(DATE_CHECKOUT - BIRTH_DATE);

select count(DISTINCT CUSTOMERS_ID), PRICE, PAGES, DURATION, gender from books_1 a, BK_DURATION b, customers c
where a.id = b.books_id and b.customers_id = c.id
group by PRICE, PAGES, DURATION, gender;

select * from BK_DURATION;

trim(to_char(((CLR_BAL_AMT + SANCT_LIM)


select * from books_1;

select * from checkouts;

--------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

select * from customers;

select count(distinct id) from customers;---2000

select count(id) from customers;---2000

select count(distinct id), state from customers
group by state
;
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

select * from libraries;

select count(distinct id) from libraries;---18
----------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

----Count of unique books
select count(distinct BOOKS_ID) from checkouts;----240

----Count of unique customers
select count(distinct CUSTOMERS_ID) from checkouts;----2000

select count(distinct LIBRARY_ID) from checkouts;----18

select count(distinct ID), NAME from libraries
group by NAME
ORDER BY 2;

select * from checkouts;

---------------------------------------------------------------------------------------------------
select * from customers 
where birth_date = '01-jan-2050';

select * from books_1;

select * from libraries;

select * from checkouts;


select books_id, customers_id, library_id, to_char(date_returned - date_checkout) from checkouts;


select b.*, date_returned, to_char(date_returned, 'YYYY') - to_char(birth_date, 'YYYY') from checkouts a, customers b
where a.customers_id=b.id;


Select * from customers;


Select count(distinct id) from customers
where gender like '%female%';

Select count(distinct id), gender from customers
group by gender;


----Distribution by Gender and Return Period

select count(distinct id), gender, to_char(date_returned, 'YYYY') - to_char(birth_date, 'YYYY') age, to_char(date_returned - date_checkout) duration  from customers a, checkouts b
where a.id = b.customers_id
group by gender, to_char(date_returned, 'YYYY') - to_char(birth_date, 'YYYY'), to_char(date_returned - date_checkout);

select count(distinct id), gender, case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'undefind'
end Period from (select distinct id, gender, to_char(date_returned, 'YYYY') - to_char(birth_date, 'YYYY') age, to_char(date_returned - date_checkout) duration  from customers a, checkouts b
where a.id = b.customers_id
group by id, gender, to_char(date_returned, 'YYYY') - to_char(birth_date, 'YYYY'), to_char(date_returned - date_checkout))
group by gender, case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'undefind' end;



----Distribution by Age and Return Period

select count(distinct id), gender, to_char(date_returned, 'YYYY') - to_char(birth_date, 'YYYY') age, to_char(date_returned - date_checkout) duration  from customers a, checkouts b
where a.id = b.customers_id
group by gender, to_char(date_returned, 'YYYY') - to_char(birth_date, 'YYYY'), to_char(date_returned - date_checkout);

select count(distinct id), case when age between 1 and 29 then '<30 Years'
when age between 30 and 50 then '30-50 Years'
when age between 51 and 100 then '>50'
else 'Undefined' end Age_range, 
case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'undefind'
end Period from (select distinct id, gender, to_char(date_returned, 'YYYY') - to_char(birth_date, 'YYYY') age, to_char(date_returned - date_checkout) duration  from customers a, checkouts b
where a.id = b.customers_id
group by id, gender, to_char(date_returned, 'YYYY') - to_char(birth_date, 'YYYY'), to_char(date_returned - date_checkout))
group by case when age between 1 and 29 then '<30 Years'
when age between 30 and 50 then '30-50 Years'
when age between 51 and 100 then '>50'
else 'Undefined' end, case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'undefind' end;


------Total count of Books,Customers, Libraries
 
select count(distinct id) from customers;---2000

select count(distinct id) from books_1;---240

select count(distinct id) from libraries;---18

----- of Late and Early Returned Period
select * from checkouts;

select id, case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'Undefind'
end Period 
from (select id, to_char(date_returned - date_checkout) duration  from customers a, checkouts b
where a.id = b.customers_id
group by id, to_char(date_returned - date_checkout))
;


----Line graph of Return Trend
select id, date_returned, case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'Undefind'
end Period 
from (select id, date_returned, to_char(date_returned - date_checkout) duration  from customers a, checkouts b
where a.id = b.customers_id
group by id, date_returned, to_char(date_returned - date_checkout))
;


----Distribution of Book Return Period by occupation.

select count(id), OCCUPATION from customers;

select id, occupation, case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'Undefind'
end Period from (select id, occupation, to_char(date_returned - date_checkout) duration  from customers a, checkouts b
where a.id = b.customers_id
group by id, occupation, to_char(date_returned - date_checkout))

;


----Distribution of Book Return Period by occupation.

select count(id), EDUCATION from customers;

select id, EDUCATION, case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'Undefind'
end Period from (select id, EDUCATION, to_char(date_returned - date_checkout) duration  from customers a, checkouts b
where a.id = b.customers_id
group by id, EDUCATION, to_char(date_returned - date_checkout))

;

select * from libraries;

select * from books_1;

select * from checkouts;

select * from customers;


----Distribution by Book Pages and Return Period

select count(distinct id), case when price <100.00 then '<100.00'
when price between 100 and 500 then '100.00 - 500.00'
when price >500 then '>500.00'
else 'Undefined' end price_range, 
case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'Undefind'
end Period from (select distinct id, price, to_char(date_returned - date_checkout) duration  from books_1 a, checkouts b
where a.id = b.books_id
group by id, price, to_char(date_returned - date_checkout))
group by case when price <100.00 then '<100.00'
when price between 100 and 500 then '100.00 - 500.00'
when price >500 then '>500.00'
else 'Undefined' end, case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'Undefind' end;


----Distribution by Book Pages and Return Period

select count(distinct id), case when pages <200 then '<200 Pages'
when pages between 200 and 500 then '200 - 500 Pages'
when pages >500 then '>500 Pages'
else 'Undefined' end page_range, 
case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'Undefind'
end Period from (select distinct id, pages, to_char(date_returned - date_checkout) duration  from books_1 a, checkouts b
where a.id = b.books_id
group by id, pages, to_char(date_returned - date_checkout))
group by case when pages <200 then '<200 Pages'
when pages between 200 and 500 then '200 - 500 Pages'
when pages >500 then '>500 Pages'
else 'Undefined' end, case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'Undefind' end;


select * from libraries;

select * from books_1;

select * from checkouts;

select * from customers;


----Distribution of Book Return Period by City.

select id, city, case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'Undefind'
end Period from (select id, city, to_char(date_returned - date_checkout) duration  from customers a, checkouts b
where a.id = b.customers_id
group by id, city, to_char(date_returned - date_checkout))
;


----Distribution of Book Return Period by City.

select id, state, case when duration between 1 and 28 then '<=28days (Early Return)'
when duration between 29 and 1000 then '>28days (Late Return)'
else 'Undefind'
end Period from (select id, state, to_char(date_returned - date_checkout) duration  from customers a, checkouts b
where a.id = b.customers_id
group by id, state, to_char(date_returned - date_checkout))







