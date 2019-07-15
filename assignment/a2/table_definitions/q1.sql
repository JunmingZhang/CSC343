-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS vote_result CASCADE;
DROP VIEW IF EXISTS win_party CASCADE;
DROP VIEW IF EXISTS win_count CASCADE;
DROP VIEW IF EXISTS avg_count CASCADE;
DROP VIEW IF EXISTS max_date CASCADE;
DROP VIEW IF EXISTS recentlyMost CASCADE;
DROP VIEW IF EXISTS morethanThree CASCADE;
DROP VIEW IF EXISTS recently_more_win_party CASCADE;
DROP VIEW IF EXISTS final_answer CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW vote_result AS
SELECT election_id, max(votes) as max_votes
FROM election_result
GROUP BY election_id;

CREATE VIEW win_party AS 
SELECT e.party_id as party_id, v.election_id as election_id
FROM vote_result v, election_result e
WHERE v.max_votes = e.votes
and v.election_id = e.election_id;

CREATE VIEW win_count AS
SELECT count(w.election_id) as wonElections, p.id as partyId, p.name as partyName, p.country_id AS country_id
FROM win_party w RIGHT JOIN party p on w.party_id = p.id
GROUP BY p.id, country_id;

CREATE VIEW avg_count AS
SELECT avg(wonElections) as avg_times, country_id
FROM win_count
GROUP BY country_id;

CREATE VIEW max_date AS
SELECT max(e.e_date) AS recent_date, w.party_id as party_id
FROM win_party w, election e
WHERE w.election_id = e.id
GROUP BY w.party_id;

CREATE VIEW recentlyMost as
SELECT e.id as mostRecentlyWonElectionId, extract(year from e.e_date) as mostRecentlyWonElectionYear, w.party_id as party_id
FROM max_date m, election e, win_party w
WHERE e.id = w.election_id
and m.recent_date = e.e_date
and m.party_id = w.party_id;

CREATE VIEW morethanThree as
SELECT w.wonElections as wonElections, w.partyId as party_id, w.partyName as partyName, w.country_id as country_id
FROM win_count w, avg_count a
WHERE w.country_id = a.country_id
and w.wonElections > 3*a.avg_times;

CREATE VIEW recently_more_win_party as
SELECT m.party_id as party_id, m.wonElections as wonElections, m.partyName as partyName, m.country_id as country_id, r.mostRecentlyWonElectionId as mostRecentlyWonElectionId, r.mostRecentlyWonElectionYear as mostRecentlyWonElectionYear
FROM morethanThree m, recentlyMost r
WHERE m.party_id = r.party_id;

CREATE VIEW party_country as
SELECT r.party_id as party_id, c.name as countryName, r.partyName as partyName, r.wonElections as wonElections, r.mostRecentlyWonElectionId as mostRecentlyWonElectionId, r.mostRecentlyWonElectionYear as mostRecentlyWonElectionYear
FROM recently_more_win_party r, country c
WHERE r.country_id = c.id;

CREATE VIEW party_country_family as
SELECT pc.countryName as countryName, pc.partyName as partyName, pf.family as partyFamily, pc.wonElections as wonElections, pc.mostRecentlyWonElectionId as mostRecentlyWonElectionId, pc.mostRecentlyWonElectionYear as mostRecentlyWonElectionYear
FROM party_country pc LEFT JOIN party_family pf on pc.party_id = pf.party_id;


-- the answer to the query 
insert into q1
SELECT *
FROM party_country_family;


