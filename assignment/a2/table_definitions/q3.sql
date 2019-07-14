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

CREATE VIEW countryAndParty AS
SELECT country.name AS countryName, party.name AS partyName, party.id AS PId
FROM country JOIN ON party ON country.id = party.country_id;

CREATE VIEW joinFamily AS
SELECT countryName, partyName, family AS partyFamily, PId
FROM countryAndParty LEFT JOIN party_family ON
     countryAndParty.PId = party_family.party_id;

CREATE VIEW marketStatus AS
SELECT countryName, partyName, partyFamily, state_market AS stateMarket, PId
FROM joinFamily LEFT JOIN party_position ON
     joinFamily.PId = party_position.party_id;

---CREATE VIEW overTwenty AS
---SELECT countryName, partyName, partyFamily, state_market
---FROM cabinet_party cp JOIN cabinet c ON cp.cabinet_id = c.id
---                      JOIN marketStatus ON cp.party_id = marketStatus.PId
---WHERE start_date > 

-- the answer to the query 
insert into q3 (countryName, partyName, partyFamily, stateMarket) (
       SELECT countryName, partyName, partyFamily, state_market
       FROM marketStatus
);
