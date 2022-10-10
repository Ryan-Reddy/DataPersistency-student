-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S8: Extra (uitdagende) queries
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
--
--
-- Opdracht: schrijf SQL-queries om onderstaande resultaten op te vragen,
-- aan te maken, verwijderen of aan te passen in de database van de
-- bedrijfscasus.
-- ------------------------------------------------------------------------


-- S8.1.
-- Geef naam en voorletters van iedereen die ooit bij Nico Smit
-- een cursus heeft gevolgd.
SELECT cursist FROM uitvoeringen
                        JOIN inschrijvingen
                             ON
                                         uitvoeringen.cursus = inschrijvingen.cursus
                                     AND
                                         uitvoeringen.begindatum = inschrijvingen.begindatum
WHERE docent IN (
    SELECT mnr FROM medewerkers WHERE naam = 'SMIT' AND voorl = 'N'
);


-- S8.2.
-- Geef van iedere medewerker: achternaam en het jaarsalaris 
-- inclusief toelage en commissie (alias `jaarsalaris`).
SELECT naam, (maandsal*12)
    + COALESCE (toelage, 0)
    + COALESCE (comm, 0)
    AS jaarsalaris FROM medewerkers;

-- S8.3.
-- Geef van alle docenten: naam en voorletters, het aantal
-- cursussen dat ze hebben gegeven (`aantal_cursussen`),
-- het aantal cursisten dat ze hebben opgeleid (`aantal_cursisten`),
-- en het gemiddelde evaluatiecijfer (`score`). Rond de laatste
-- af op één decimaal.

-- TODO fix:
SELECT  COUNT(uitvoeringen.docent WHERE docent = 7369), mnr, naam, voorl FROM medewerkers
                                                                                  JOIN uitvoeringen ON medewerkers.mnr = uitvoeringen.docent
WHERE mnr IN (SELECT DISTINCT docent FROM uitvoeringen)


-- S8.4.
-- Geef de locatie waar op een bepaald moment twee cursussen tegelijk werd
-- gegeven.
SELECT uit1.begindatum, uit1.locatie, uit2.begindatum, uit2.locatie FROM uitvoeringen AS uit1

                                                                             JOIN uitvoeringen AS uit2
                                                                                  ON
                                                                                              uit1.begindatum = uit2.begindatum
                                                                                          AND
                                                                                              uit1.locatie = uit2.locatie
                                                                                          AND
                                                                                              uit1.cursus != uit2.cursus

-- S8.5.
-- Geef docent en cursus waarvoor geldt dat de docent de cursus éérst bij een
-- collega heeft gevolgd vóór hij de cursus zelf heeft gegeven.

-- SELECT cursist, inschrijvingen.cursus, inschrijvingen.cursus FROM inschrijvingen
-- WHERE cursist IN (SELECT docent FROM uitvoeringen)  -- docenten die ook cursist zijn geweest
--   AND inschrijvingen.cursus IN (SELECT cursus FROM uitvoeringen);

SELECT cursist, uitvoeringen.cursus, uitvoeringen.docent FROM inschrijvingen
                                                                  JOIN uitvoeringen ON cursist = docent AND uitvoeringen.cursus = inschrijvingen.cursus;

-- WHERE cursist IN (SELECT docent FROM uitvoeringen) -- alle docenten die ook cursist zijn geweest

-- SELECT * FROM uitvoeringen;
-- SELECT * FROM inschrijvingen;
-- SELECT * FROM uitvoeringen;
--
-- SELECT docent FROM uitvoeringen;


-- S8.6.
-- Geef de achternaam van alle werknemers die álle bouwcursussen ('BLD') hebben
-- gevolgd.
SELECT cursist, cursus FROM inschrijvingen
WHERE cursus IN (
    SELECT code FROM cursussen WHERE type = 'BLD'
)
  AND
    (cursist = cursist AND DISTINCT COUNT(cursus) = 3)

GROUP BY cursist, cursus