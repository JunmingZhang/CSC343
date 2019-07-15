SET SEARCH_PATH TO parlgov;

SELECT *
FROM q3
ORDER BY countryName,
      partyName,
      stateMarket DESC;
