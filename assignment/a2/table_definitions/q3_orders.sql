SET SEARCH_PATH TO parlgov;

SELECT *
FROM q3
WHERE countryName ASC,
      partyName ascending ASC,
      stateMarket DESC;