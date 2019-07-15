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
DROP VIEW IF EXISTS NationalCabinet CASCADE;
DROP VIEW IF EXISTS ToCabinet CASCADE;
DROP VIEW IF EXISTS NationalCabinetWithEnd CASCADE;
DROP VIEW IF EXISTS PartyName CASCADE;
DROP VIEW IF EXISTS CabinetPmKnown CASCADE;

-- Define views for your intermediate steps here.

-- display countryNanme, cabinetId and startDate
CREATE VIEW NationalCabinet AS
SELECT country.name AS countryName,
       cabinet.id AS cabinetId, start_date AS startDate
FROM cabinet JOIN country ON country.id = cabinet.country_id;

-- pick up cabinetId to join with the correct cabinet
CREATE VIEW ToCabinet AS
SELECT cabinet_id AS cabinetId, end_date, cabinet_party.party_id as party_id
FROM  cabinet_party LEFT JOIN politician_president ON politician_president.party_id = cabinet_party.party_id;

-- add end date to the view
-- end date of the previous cabinet is the start date of this cabinet
CREATE VIEW NationalCabinetWithEnd AS
SELECT countryName, NationalCabinet.cabinetId, startDate, cabinet.start_date AS endDate
FROM NationalCabinet Left JOIN cabinet ON cabinet.previous_cabinet_id = cabinetID;

-- find the name of the party fills the PM
-- also add cabinetId for later joining the name of the party with PM
CREATE VIEW PartyName AS
SELECT party.name AS partyName, cabinet_id
FROM cabinet_party, party
WHERE cabinet_party.party_id = party.id AND pm = True;

-- join the name of the party with PM
CREATE VIEW CabinetPmKnown AS
SELECT countryName, cabinetId, startDate, endDate, partyName AS pmParty
FROM NationalCabinetWithEnd LEFT JOIN PartyName ON NationalCabinetWithEnd.cabinetID = PartyName.cabinet_id;


-- the answer to the query 
insert into q4 (countryName, cabinetId, startDate, endDate, pmParty) (
        SELECT countryName, cabinetId, startDate, endDate, pmParty
        FROM CabinetPmKnown
);
