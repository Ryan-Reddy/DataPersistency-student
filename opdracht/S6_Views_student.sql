-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S6: Views
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- ------------------------------------------------------------------------


-- S6.1.
--
-- 1. Maak een view met de naam "deelnemers" waarmee je de volgende gegevens uit de tabellen inschrijvingen en uitvoering combineert:
--    inschrijvingen.cursist, inschrijvingen.cursus, inschrijvingen.begindatum, uitvoeringen.docent, uitvoeringen.locatie
CREATE OR REPLACE VIEW deelnemers AS SELECT inschrijvingen.cursist, inschrijvingen.cursus, inschrijvingen.begindatum FROM inschrijvingen
	JOIN uitvoeringen ON inschrijvingen.cursus = uitvoeringen.cursus and inschrijvingen.begindatum = uitvoeringen.begindatum;


-- 2. Gebruik de view in een query waarbij je de "deelnemers" view combineert met de "personeels" view (behandeld in de les):
    CREATE OR REPLACE VIEW personeel AS
	     SELECT mnr, voorl, naam as medewerker, afd, functie
      FROM medewerkers;
	  
SELECT * FROM deelnemers JOIN personeel ON personeel.mnr = deelnemers.cursist;


-- 3. Is de view "deelnemers" updatable ? Waarom ?


-- S6.2.
--
-- 1. Maak een view met de naam "dagcursussen". Deze view dient de gegevens op te halen: 
--      code, omschrijving en type uit de tabel curssussen met als voorwaarde dat de lengte = 1. Toon aan dat de view werkt. 
CREATE OR REPLACE VIEW dagcursussen AS
	SELECT code, omschrijving, type FROM cursussen WHERE lengte = 1;
	
	SELECT * FROM dagcursussen;


-- 2. Maak een tweede view met de naam "daguitvoeringen". 
--    Deze view dient de uitvoeringsgegevens op te halen voor de "dagcurssussen" (gebruik ook de view "dagcursussen"). Toon aan dat de view werkt

CREATE OR REPLACE VIEW daguitvoeringen AS
	SELECT * FROM uitvoeringen JOIN dagcursussen ON dagcursussen.code = uitvoeringen.cursus;
	
SELECT * FROM daguitvoeringen;
	
	
-- 3. Verwijder de views en laat zien wat de verschillen zijn bij DROP view <viewnaam> CASCADE en bij DROP view <viewnaam> RESTRICT
DROP VIEW deelnemers RESTRICT; -- werkt maar laat personeel in zn waarde
SELECT * FROM deelnemers;  -- is nu verwijderd
SELECT * FROM personeel;   -- bestaat nog vanwege RESTRICT

DROP VIEW deelnemers CASCADE;
SELECT * FROM deelnemers;  -- is nu verwijderd 
SELECT * FROM personeel;   -- is nu verwijderd dmv CASCADE ook de gelinkde database verwijderd



DROP VIEW personeel RESTRICT;

DROP VIEW personeel CASCADE;

DROP VIEW dagcursussen RESTRICT;
DROP VIEW dagcursussen CASCADE;

DROP VIEW daguitvoeringen RESTRICT;
DROP VIEW daguitvoeringen CASCADE;






















