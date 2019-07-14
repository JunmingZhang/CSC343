-- Alliances

SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q5 CASCADE;
CREATE TABLE q5(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- filter out info needed for a single party
CREATE VIEW PartyInCountry AS
SELECT ER.id AS ERId, ER.party_id AS partyId, ER.election_id AS ElectionId,
       ER.alliance_id AS AllianceId, party.country_id AS CoID
FROM election_result ER JOIN party ON party.id = ER.party_id;

-- find all alliances in a country
CREATE VIEW AlliancePairs AS
SELECT P1.CoID AS CoID, P1.partyID AS P1Id, P2.partyID AS P2Id, count(*) AS numPairs
FROM PartyInCountry P1, PartyInCountry P2
WHERE P1.ElectionId = P2.ElectionId AND
      P1.CoID = P2.CoID AND
      P1.party_id < P2.party_id AND
      (P1.ERId = P2.AllianceId OR
       P2.ERId = P1.AllianceId OR
       P1.AllianceId = P2.AllianceId)
GROUP BY CoID, P1Id, P2Id;

-- find the total number of elections in a country
CREATE VIEW numElections AS
SELECT country.id AS CoID, count(*) AS numElcs
FROM election
GROUP BY CoID;

-- find the the pair of parties made allicances in more than 30% elections
CREATE VIEW AllianceResult AS
SELECT AP.CoID AS countryId, P1.P1Id AS alliedPartyId1, P2.P1Id AS alliedPartyId1
FROM AlliancePairs AP JOIN numElections NE ON AP.CoID = NE.CoID
WHERE CAST(numPairs AS float) / CAST(numElcs AS float) >= 0.3;

-- the answer to the query 
insert into q5 (countryId, alliedPartyId1, alliedPartyId1) (
    SELECT countryId, alliedPartyId1, alliedPartyId1
    FROM AllianceResult
);
