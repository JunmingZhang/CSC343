-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS country_with_year_reatio CASCADE;
DROP VIEW IF EXISTS in2001_2016 CASCADE;
DROP VIEW IF EXISTS avg_Ratio CASCADE;
DROP VIEW IF EXISTS country_decreasing CASCADE;
DROP VIEW IF EXISTS country_NonDecreasing CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW country_with_year_reatio AS
SELECT c.id as countryId, c.name as countryName, extract(year from e.e_date) as year, cast(e.votes_cast as float)/cast(e.electorate as float) AS participationRatio
FROM election e, country c
WHERE c.id = e.country_id;

CREATE VIEW in2001_2016 AS
SELECT countryId, countryName, year, participationRatio
FROM country_with_year_reatio
WHERE year >= 2001 and year <= 2016;

CREATE VIEW avg_Ratio as
SELECT countryId, countryName, year, avg(participationRatio) as participationRatio
FROM in2001_2016
GROUP BY countryId, countryName, year;

CREATE VIEW country_decreasing as
SELECT r1.countryId as countryId, r1.countryName as countryName
FROM avg_Ratio r1, avg_Ratio r2
WHERE r1.countryId = r2.countryId and r1.countryName = r2.countryName and r1.year < r2.year and r1.participationRatio > r2.participationRatio;

CREATE VIEW country_NonDecreasing as
SELECT countryName, year, participationRatio
FROM avg_Ratio
WHERE countryId not in (
	SELECT countryId
	FROM country_decreasing);


-- the answer to the query 
insert into q2
SELECT *
FROM country_NonDecreasing;

