SET search path TO parlgov

SELECT *
from q1
ORDER BY countryName, wonElections, partyName DESC;
