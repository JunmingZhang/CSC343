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

CREATE VIEW pastTwentyYearCabinets AS
SELECT id AS CaId, country_id AS CoId
FROM cabinet
WHERE (extract(YEAR, start_date) >= 1999) AND (extract(YEAR, start_date) <= 2019);

CREATE VIEW allCombos AS
SELECT CoId, party.id AS PId, CaId
FROM pastTwentyYearCabinets JOIN party ON party.country_id = CoId;

CREATE VIEW inCabinet AS
SELECT country_id AS CoId, party.id AS PId, cabinet_id AS CaId
FROM cabinet_party cp JOIN party ON cp.party_id = party.id;

CREATE VIEW notAlways AS
(SELECT *
FROM allCombos) EXCEPT
(SELECT *
FROM inCabinet);

CREATE VIEW commited AS
(SELECT country_id AS CoId, party.id AS PId
FROM party) EXCEPT
(SELECT CoId, PId
FROM notAlways);

CREATE VIEW answer AS
SELECT co.name AS countryName, p.name AS partyName,
       pf.party_family AS partyFamily, pp.state_market AS stateMarket
FROM commited JOIN country co ON commited.CoId = co.id
              JOIN party p ON commited.PId = p.id
              LEFT JOIN party_family AS pf On commited.PId = pf.party_id
              LEFT JOIN party_position pp ON commited.PId = pp.party_id;


---CREATE VIEW overTwenty AS
---SELECT countryName, partyName, partyFamily, state_market
---FROM cabinet_party cp JOIN cabinet c ON cp.cabinet_id = c.id
---                      JOIN marketStatus ON cp.party_id = marketStatus.PId
---WHERE start_date > 

-- the answer to the query 
insert into q3 (countryName, partyName, partyFamily, stateMarket) (
        SELECT countryName, partyName, partyFamily, stateMarket
        FROM answer
);
