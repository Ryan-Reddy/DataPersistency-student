-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S3: Multiple Tables
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
--
--
-- Opdracht: schrijf SQL-queries om onderstaande resultaten op te vragen,
-- aan te maken, verwijderen of aan te passen in de database van de
-- bedrijfscasus.
--
-- Codeer je uitwerking onder de regel 'DROP VIEW ...' (bij een SELECT)
-- of boven de regel 'ON CONFLICT DO NOTHING;' (bij een INSERT)
-- Je kunt deze eigen query selecteren en los uitvoeren, en wijzigen tot
-- je tevreden bent.
--
-- Vervolgens kun je je uitwerkingen testen door de testregels
-- (met [TEST] erachter) te activeren (haal hiervoor de commentaartekens
-- weg) en vervolgens het hele bestand uit te voeren. Hiervoor moet je de
-- testsuite in de database hebben geladen (bedrijf_postgresql_test.sql).
-- NB: niet alle opdrachten hebben testregels.
--
-- Lever je werk pas in op Canvas als alle tests slagen.
-- ------------------------------------------------------------------------


-- S3.1.
-- Produceer een overzicht van alle cursusuitvoeringen; geef de
-- code, de begindatum, de lengte en de naam van de docent.
-- DROP VIEW IF EXISTS s3_1; CREATE OR REPLACE VIEW s3_1 AS                                                     -- [TEST]
SELECT code, begindatum, lengte, medw.naam
FROM cursussen AS cursus
         JOIN uitvoeringen AS uitv
              ON cursus.code = uitv.cursus
         JOIN medewerkers as medw
              ON uitv.docent = medw.mnr
ORDER BY begindatum;

-- S3.2.
-- Geef in twee kolommen naast elkaar de achternaam van elke cursist (`cursist`)
-- van alle S02-cursussen, met de achternaam van zijn cursusdocent (`docent`).
-- DROP VIEW IF EXISTS s3_2; CREATE OR REPLACE VIEW s3_2 AS                                                     -- [TEST]

SELECT cursist, code, medewerkers.naam as docent
from inschrijvingen
         JOIN cursussen
              ON inschrijvingen.cursus = cursussen.code
         JOIN uitvoeringen
              ON cursussen.code = uitvoeringen.cursus
         JOIN medewerkers
              ON uitvoeringen.docent = medewerkers.mnr
WHERE cursussen.code = 'S02'
;



-- S3.3.
-- Geef elke afdeling (`afdeling`) met de naam van het hoofd van die
-- afdeling (`hoofd`).
-- DROP VIEW IF EXISTS s3_3; CREATE OR REPLACE VIEW s3_3 AS                                                     -- [TEST]

SELECT afd.naam AS afdeling, afd.locatie, mdw.naam AS hoofd
FROM afdelingen AS afd
         JOIN medewerkers AS mdw
              ON afd.hoofd = mdw.mnr;


-- S3.4.
-- Geef de namen van alle medewerkers, de naam van hun afdeling (`afdeling`)
-- en de bijbehorende locatie.
-- DROP VIEW IF EXISTS s3_4; CREATE OR REPLACE VIEW s3_4 AS                                                     -- [TEST]

SELECT mdw.naam, afdelingen.naam AS afdeling, afdelingen.locatie AS locatie
FROM medewerkers AS mdw
         JOIN afdelingen AS afdelingen
              ON mdw.afd = afdelingen.anr;

-- S3.5.
-- Geef de namen van alle cursisten die staan ingeschreven voor de cursus S02 van 12 april 2019
-- DROP VIEW IF EXISTS s3_5; CREATE OR REPLACE VIEW s3_5 AS                                                     -- [TEST]

SELECT voorl, naam
FROM inschrijvingen
         JOIN medewerkers
              ON medewerkers.mnr = inschrijvingen.cursist
WHERE cursus = 'S02'
  AND begindatum = to_date('2019-04-12', YYYY-DD-MM)
;

-- S3.6.
-- Geef de namen van alle medewerkers en hun toelage.
-- DROP VIEW IF EXISTS s3_6; CREATE OR REPLACE VIEW s3_6 AS                                                     -- [TEST]

SELECT naam, toelage FROM medewerkers;

-- -------------------------[ HU TESTRAAMWERK ]--------------------------------
-- Met onderstaande query kun je je code testen. Zie bovenaan dit bestand
-- voor uitleg.

SELECT *
FROM test_select('S3.1') AS resultaat
UNION
SELECT *
FROM test_select('S3.2') AS resultaat
UNION
SELECT *
FROM test_select('S3.3') AS resultaat
UNION
SELECT *
FROM test_select('S3.4') AS resultaat
UNION
SELECT *
FROM test_select('S3.5') AS resultaat
UNION
SELECT *
FROM test_select('S3.6') AS resultaat
ORDER BY resultaat;

