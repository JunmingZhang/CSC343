drop schema if exists nulls cascade;
create schema nulls;
set search_path to nulls;

--
create table Runnymede(name text, age int, grade int);
insert into Runnymede values
('diane', null, 8), ('will', null, 8), ('cate', null, 1), ('tom', null, null), 
('micah', null, 1), ('grace', null, 2);

--
create table R(a int, b int);
insert into R values
(1, 2), (8, 7), (5, null), (null, 6);

create table T(b int, c int);
insert into T values
(2, 5), (2, 9), (1, 4), (null, 18), (6, 88);

-- 
create table names(first text, last text, unique (first, last));