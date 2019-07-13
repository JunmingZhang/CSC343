SET SEARCH_PATH TO parlgov;

SELECT *
FROM q5
ORDER BY countryId DESC,
         alliedPartyId1 DESC,
         alliedPartyId2 DESC;