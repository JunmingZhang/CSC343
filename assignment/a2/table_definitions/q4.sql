-- Sequences

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.

CREATE TABLE q4(
        countryName VARCHAR(50),
        cabinetId INT, 
        startDate DATE,
        endDate DATE,
        pmParty VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- display countryNanme, cabinetID and startDate
-- also pick up countryID as coID for joining
CREATE VIEW NationalCabinet AS
SELECT country.id AS CoID, country.name AS countryName, cabinet.id AS cabinetID, start_date AS startDate
FROM cabinet JOIN country ON country.id = cabinet.country_id;

-- add end date to the view
-- also add partyID for later joining the name of the party with PM
CREATE VIEW NationalCabinetWithEnd AS
SELECT countryName, cabinetID, startDate, end_date AS endDate, party_id AS partyID
FROM NationalCabinet JOIN politician_president ON CoID = politician_president.country_id;

-- find the name of the party fills the PM
-- also add partyID for later joining the name of the party with PM
CREATE VIEW PartyName AS
SELECT party.name AS partyName, party.id AS partyID
FROM cabinet_party, party
WHERE cabinet_party.party_id = party.id AND pm = True;

-- join the name of the party with PM
CREATE VIEW CabinetPmKnown AS
SELECT countryName, cabinetID, startDate, endDate, partyName AS pmParty
FROM NationalCabinetWithEnd LEFT JOIN PartyName ON NationalCabinetWithEnd.partyID = PartyName.partyID;



-- the answer to the query 
insert into q4 (countryName, cabinetID, startDate, endDate, pmParty) (
        SELECT countryName, cabinetID, startDate, endDate, pmParty
        FROM CabinetPmKnown
);
