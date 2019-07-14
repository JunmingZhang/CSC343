-- Committed

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

CREATE TABLE q3(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- pick up cabinets in past 20 years
CREATE VIEW pastTwentyYearCabinets AS
SELECT id AS CaId, country_id AS CoId
FROM cabinet
WHERE (EXTRACT(YEAR FROM start_date) >= 1999) AND (EXTRACT(YEAR FROM start_date) <= 2019);

-- find all combinations of parties in the cabinets
CREATE VIEW allCombos AS
SELECT CoId, party.id AS PId, CaId
FROM pastTwentyYearCabinets JOIN party ON party.country_id = CoId;

-- select info needed for cabinets
CREATE VIEW inCabinet AS
SELECT country_id AS CoId, party.id AS PId, cabinet_id AS CaId
FROM cabinet_party cp JOIN party ON cp.party_id = party.id;

-- find parties not always commited
CREATE VIEW notAlways AS
(SELECT *
FROM allCombos) EXCEPT
(SELECT *
FROM inCabinet);

-- find commited parties
CREATE VIEW commited AS
(SELECT country_id AS CoId, party.id AS PId
FROM party) EXCEPT
(SELECT CoId, PId
FROM notAlways);

-- find the answer
CREATE VIEW answer AS
SELECT co.name AS countryName, p.name AS partyName,
       pf.family AS partyFamily, pp.state_market AS stateMarket
FROM commited JOIN country co ON commited.CoId = co.id
              JOIN party p ON commited.PId = p.id
              LEFT JOIN party_family pf ON commited.PId = pf.party_id
              LEFT JOIN party_position pp ON commited.PId = pp.party_id;


-- the answer to the query 
insert into q3 (countryName, partyName, partyFamily, stateMarket) (
        SELECT countryName, partyName, partyFamily, stateMarket
        FROM answer
);
