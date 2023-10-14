create database PKP220;
use PKP220;
create table Crowdfunding_projects_1(
id bigint default null,
state text,
name text,
country text,
creator_id bigint default null,
location_id bigint default null,
category_id bigint default null,
created_at bigint default null,
deadline bigint default null,
updated_at bigint default null,
state_changed_at bigint default null,
successful_at bigint default null,
launched_at bigint default null,
goal int default null,
pledged float default null,
currency text,
currency_symbol varchar(50) default null,
usd_pledged float default null,
static_usd_rate float default null,
backers_count bigint default null);

select*from  Crowdfunding_projects_1;
load data infile 'D:/DA/Crowdfunding_projects_1.csv' into table  Crowdfunding_projects_1
fields terminated by ','
ignore 1 lines;

select*from crowdfunding_projects_1;
---------- CONVERT TIME EPOCH ---------------
ALTER TABLE crowdfunding_projects_1
ADD COLUMN nat_time_creator DATE;
UPDATE crowdfunding_projects_1
SET nat_time_creator = from_unixtime(floor(creator_id));
set sql_safe_updates=0;
------------ Year ----------
ALTER TABLE crowdfunding_projects_1
ADD COLUMN year_column INT;
UPDATE crowdfunding_projects_1
SET year_column = YEAR(nat_time_creator);
------------ Month ------------------
ALTER TABLE crowdfunding_projects_1
ADD COLUMN month_column INT;
UPDATE crowdfunding_projects_1
SET month_column = month(nat_time_creator);
------------- Full month name ---------------
ALTER TABLE crowdfunding_projects_1
ADD COLUMN monthname_column char(10);
UPDATE crowdfunding_projects_1
SET monthname_column = monthname(nat_time_creator);
--------------- Quarter -----------------
ALTER TABLE crowdfunding_projects_1
ADD COLUMN quarter_column VARCHAR(5);
UPDATE crowdfunding_projects_1
SET quarter_column = CONCAT('Q', QUARTER(nat_time_creator));
------------------ YearMonth ------------------
ALTER TABLE crowdfunding_projects_1
ADD COLUMN year_month_column VARCHAR(8);
UPDATE crowdfunding_projects_1
SET year_month_column = DATE_FORMAT(nat_time_creator, '%Y-%b');
-------------------- Weekday number ------------------
ALTER TABLE crowdfunding_projects_1
ADD weekday_number INT;
UPDATE crowdfunding_projects_1
SET weekday_number = weekday(nat_time_creator);
---------------- Weekday_Name --------------------
ALTER TABLE crowdfunding_projects_1
ADD weekday_name char(10);
UPDATE crowdfunding_projects_1
SET weekday_number = weekday(nat_time_creator);
-------------------- Financial Month--------------------
ALTER TABLE crowdfunding_projects_1
ADD COLUMN financial_month INT;
UPDATE crowdfunding_projects_1
SET financial_month = 
    CASE 
        WHEN MONTH(nat_time_creator) >= 4 THEN MONTH(nat_time_creator) - 3
        ELSE MONTH(nat_time_creator) + 9
    END;
--------------------- Financial Quarter --------------------------
ALTER TABLE crowdfunding_projects_1
ADD financial_quarter varchar(5);
UPDATE crowdfunding_projects_1
SET financial_quarter = 
  CONCAT('Q', 
         CASE 
           WHEN MONTH(nat_time_creator) BETWEEN 4 AND 6 THEN '1'
           WHEN MONTH(nat_time_creator) BETWEEN 7 AND 9 THEN '2'
           WHEN MONTH(nat_time_creator) BETWEEN 10 AND 12 THEN '3'
           WHEN MONTH(nat_time_creator) BETWEEN 1 AND 3 THEN '4'
         END
  );
  
--------------------- convert to USD --------------------------
select goal*static_usd_rate as USD_goal from crowdfunding_projects_1;
--------------------- project overview --------------------------
--------------------- base on outcome --------------------------
select state,
count(id) as Total_no_project
from crowdfunding_projects_1
group by state;
--------------------- base on project location --------------------------
select type,
count(id) as Total_no_location
from crowdfunding_location
group by type;
--------------------- base on category --------------------------
select name,
count(id) as Total_no_category
from crowdfunding_category
group by name;
--------------------- base on year, month, quarter --------------------------
select year_column,quarter_column,monthname_column,
count(id) as Total_no_project
from crowdfunding_projects_1
group by year_column,quarter_column,monthname_column;
--------------------- successful project --------------------------
--------------------- base on amount raised --------------------------
select state,
count(id) as Total_no_project,goal
from crowdfunding_projects_1
where state = "successful"
group by goal
limit 10;
--------------------- base on no. backers --------------------------
select state,
count(id) as Total_no_project,backers_count
from crowdfunding_projects_1
where state = "successful"
group by backers_count
limit 10;
--------------------- base on avg. no. days --------------------------
select state,
count(id) as Total_no_project,
avg(weekday_number) as avg_weekdays
from crowdfunding_projects_1
where state = "successful"
group by id;
--------------------- top successful project --------------------------
--------------------- base backers --------------------------
select state,
count(id) as Total_no_project, backers_count
from crowdfunding_projects_1
where state = "successful"
group by backers_count
order by backers_count desc
limit 10;
--------------------- base on amount raised --------------------------
select state,
count(id) as Total_no_project,goal
from crowdfunding_projects_1
where state = "successful"
group by goal
order by goal desc
limit 10;
--------------------- percent of successful project overall --------------------------
select(select count(state) from crowdfunding_projects_1 where state = "successful")
/count(id)*100 as percent_of_successful 
from crowdfunding_projects_1;
--------------------- percent of successful project category --------------------------
select
(select count(state) from crowdfunding_projects_1 where state = "successful")
/count(crowdfunding_category.id)*100 as percent_of_successful,
crowdfunding_category.name
from crowdfunding_projects_1 inner join crowdfunding_category
on crowdfunding_projects_1.category_id = crowdfunding_category.id
group by crowdfunding_category.name;
--------------------- percent of successful project year --------------------------
select
(select count(state) from crowdfunding_projects_1 where state = "successful")
/count(id)*100 as percent_of_successful, year_column
from crowdfunding_projects_1
group by year_column
order by year_column;
--------------------- percent of successful project goal --------------------------
select
(select count(state) from crowdfunding_projects_1 where state = "successful")
/count(id)*100 as percent_of_successful, goal
from crowdfunding_projects_1
group by goal
order by goal desc;