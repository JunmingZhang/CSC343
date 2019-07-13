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

-- display countryNanme, cabinetId and startDate
-- also pick up countryID as coID for joining
CREATE VIEW NationalCabinet AS
SELECT country.id AS CoID, country.name AS countryName, cabinet.id AS cabinetId, start_date AS startDate
FROM cabinet JOIN country ON country.id = cabinet.country_id;

-- pick up cabinetId to join with the correct cabinet
CREATE VIEW ToCabinet AS
SELECT politician_president.country_id AS CoID, cabinet_id AS cabinetId, end_date
FROM politician_president JOIN cabinet_party ON politician_president.party_id = cabinet_party.party_id

-- add end date to the view
-- also add partyID for later joining the name of the party with PM
CREATE VIEW NationalCabinetWithEnd AS
SELECT countryName, NationalCabinet.cabinetId, startDate, end_date AS endDate, party_id AS partyID
FROM NationalCabinet JOIN ToCabinet ON NationalCabinet.CoID = ToCabinet.CoID
                                    AND NationalCabinet.cabinetId = ToCabinet.cabinetId;

-- find the name of the party fills the PM
-- also add partyID for later joining the name of the party with PM
CREATE VIEW PartyName AS
SELECT party.name AS partyName, party.id AS partyID
FROM cabinet_party, party
WHERE cabinet_party.party_id = party.id AND pm = True;

-- join the name of the party with PM
CREATE VIEW CabinetPmKnown AS
SELECT countryName, cabinetId, startDate, endDate, partyName AS pmParty
FROM NationalCabinetWithEnd LEFT JOIN PartyName ON NationalCabinetWithEnd.partyID = PartyName.partyID;



-- the answer to the query 
insert into q4 (countryName, cabinetId, startDate, endDate, pmParty) (
        SELECT countryName, cabinetId, startDate, endDate, pmParty
        FROM CabinetPmKnown
);
