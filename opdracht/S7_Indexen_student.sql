-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S7: Indexen
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- ------------------------------------------------------------------------
-- LET OP, zoals in de opdracht op Canvas ook gezegd kun je informatie over
-- het query plan vinden op: https://www.postgresql.org/docs/current/using-explain.html


-- S7.1.
--
-- Je maakt alle opdrachten in de 'sales' database die je hebt aangemaakt en gevuld met
-- de aangeleverde data (zie de opdracht op Canvas).
--
-- Voer het voorbeeld uit wat in de les behandeld is:
-- 1. Voer het volgende EXPLAIN statement uit:
--    EXPLAIN SELECT * FROM order_lines WHERE stock_item_id = 9;
--    Bekijk of je het resultaat begrijpt. Kopieer het explain plan onderaan de opdracht

EXPLAIN
SELECT *
FROM order_lines
WHERE stock_item_id = 9;

--
Seq Scan on order_lines  (cost=0.00..39.61 rows=6 width=97)
  Filter: (stock_item_id = 9)
cost = de tijd dat de query duurt
rows = rijen gescanned
width = totale cellen bekeken in de rijen zelf, de breedte

    Filter = gebruikte filter



-- 2. Voeg een index op stock_item_id toe:
--    CREATE INDEX ord_lines_si_id_idx ON order_lines (stock_item_id);
-- 3. Analyseer opnieuw met EXPLAIN hoe de query nu uitgevoerd wordt
--    Kopieer het explain plan onderaan de opdracht

"QUERY PLAN"
"Bitmap Heap Scan on order_lines  (cost=4.32..19.21 rows=6 width=97)"
"  Recheck Cond: (stock_item_id = 9)"
"  ->  Bitmap Index Scan on ord_lines_si_id_idx  (cost=0.00..4.32 rows=6 width=0)"
"        Index Cond: (stock_item_id = 9)"


-- 4. Verklaar de verschillen. Schrijf deze hieronder op.
het kost veel meer tijd
dit en wel evenveel rijen en width
    Voert een Heap scan uit
    op de query zelf

-- S7.2.
--
-- 1. Maak de volgende twee query’s:
-- 	  A. Toon uit de order tabel de order met order_id = 73590
SELECT *
FROM orders
WHERE order_id = 73590;
Index Scan using pk_sales_orders on orders  (cost=0.29..8.31 rows=1 width=155)
  Index Cond: (order_id = 73590)

-- 	  B. Toon uit de order tabel de order met customer_id = 1028
SELECT *
FROM orders
WHERE customer_id = 1028;
Seq Scan on orders  (cost=0.00..1819.94 rows=107 width=155)
  Filter: (customer_id = 1028)

-- 2. Analyseer met EXPLAIN hoe de query’s uitgevoerd worden en kopieer het explain plan onderaan de opdracht
-- 3. Verklaar de verschillen en schrijf deze op
    A.  index scan moet alle niet geskipde rijen ophalen uit de tabel en is dus meer costly
    B.  zoekt met seq scan dit lijkt sneller in dit geval, maar waarschijnlijk alleen doordat deze maar 1028 rijen hoeft te controleren

-- 4. Voeg een index toe, waarmee query B versneld kan worden
CREATE INDEX customer_id_index ON orders (customer_id);

-- 5. Analyseer met EXPLAIN en kopieer het explain plan onder de opdracht
Bitmap Heap Scan on orders  (cost=5.12..308.96 rows=107 width=155)
      ->  Bitmap Index Scan on customer_id_index  (cost=0.00..5.10 rows=107 width=0)
            Index Cond: (customer_id = 1028)
-- 6. Verklaar de verschillen en schrijf hieronder op
    Dit maal nog veeel sneller, BITMAP index scan
    dit keer maar 0 width vergeleken met 155
    hij heeft dus geen rijen hoeven scannen dmv van de index

-- S7.3.A
--
-- Het blijkt dat customers regelmatig klagen over trage bezorging van hun bestelling.
-- Het idee is dat verkopers misschien te lang wachten met het invoeren van de bestelling in het systeem.
-- Daar willen we meer inzicht in krijgen.

-- We willen alle orders (order_id, order_date, salesperson_person_id (als verkoper),
--    het verschil tussen expected_delivery_date en order_date (als levertijd),  
--    en de bestelde hoeveelheid van een product zien (quantity uit order_lines).
SELECT orders.order_id,
       order_date,
       salesperson_person_id                 AS verkoper,
       (expected_delivery_date - order_date) AS levertijd,
       quantity
FROM orders
         JOIN order_lines ON orders.order_id = order_lines.order_id;


-- Dit willen we alleen zien voor een bestelde hoeveelheid van een product > 250
--   (we zijn nl. als eerste geïnteresseerd in grote aantallen want daar lijkt het vaker mis te gaan)
SELECT orders.order_id,
       order_date,
       salesperson_person_id                 AS verkoper,
       (expected_delivery_date - order_date) AS levertijd,
       quantity
FROM orders
         JOIN order_lines ON orders.order_id = order_lines.order_id
WHERE quantity > 250;

-- En verder willen we ons focussen op verkopers wiens bestellingen er gemiddeld langer over doen.
-- De meeste bestellingen kunnen binnen een dag bezorgd worden, sommige binnen 2-3 dagen.
-- Het hele bestelproces is er op gericht dat de gemiddelde bestelling binnen 1.45 dagen kan worden bezorgd.
-- We willen in onze query dan ook alleen de verkopers zien wiens gemiddelde levertijd 
--  (expected_delivery_date - order_date) over al zijn/haar bestellingen groter is dan 1.45 dagen.
-- Maak om dit te bereiken een subquery in je WHERE clause.
SELECT orders.order_id,
       order_date,
       salesperson_person_id                 AS verkoper,
       (expected_delivery_date - order_date) AS levertijd,
       quantity
FROM orders
         JOIN order_lines ON orders.order_id = order_lines.order_id
WHERE quantity >= 250
  AND (expected_delivery_date - order_date) > 1.45;

-- Sorteer het resultaat van de hele geheel op levertijd (desc) en verkoper.
-- 1. Maak hieronder deze query (als je het goed doet zouden er 377 rijen uit moeten komen, en het kan best even duren...)
SELECT orders.order_id,
       order_date,
       salesperson_person_id                 AS verkoper,
       (expected_delivery_date - order_date) AS levertijd,
       quantity
FROM orders
         JOIN order_lines ON orders.order_id = order_lines.order_id
WHERE quantity >= 250
ORDER BY levertijd DESC

-- S7.3.B
--
-- 1. Vraag het EXPLAIN plan op van je query (kopieer hier, onder de opdracht)
-- 2. Kijk of je met 1 of meer indexen de query zou kunnen versnellen
-- 3. Maak de index(en) aan en run nogmaals het EXPLAIN plan (kopieer weer onder de opdracht) 
-- 4. Wat voor verschillen zie je? Verklaar hieronder.

ZONDER INDEX
    Sort  (cost=62.87..62.92 rows=19 width=20)
          Sort Key: ((orders.expected_delivery_date - orders.order_date)) DESC
  ->  Merge Join  (cost=40.31..62.47 rows=19 width=20)
        Merge Cond: (orders.order_id = order_lines.order_id)
        ->  Index Scan using pk_sales_orders on orders  (cost=0.29..2819.22 rows=73595 width=16)
        ->  Sort  (cost=40.02..40.06 rows=19 width=8)
              Sort Key: order_lines.order_id
              ->  Seq Scan on order_lines  (cost=0.00..39.61 rows=19 width=8)
                    Filter: (quantity >= 250)

-- GEEN EFFECT

-- CREATE INDEX expected_delivery_date_index ON orders (expected_delivery_date);
-- CREATE INDEX order_date_index ON orders (order_date);
-- CREATE INDEX order_id_index ON orders (order_id);
-- CREATE INDEX order_id ON order_lines (order_id);
-- CREATE INDEX levertijd ON orders ((orders.expected_delivery_date - orders.order_date));


-- WEL EFFECT:

CREATE INDEX quantity ON order_lines (quantity);
Sort  (cost=51.16..51.20 rows=19 width=20)
      Sort Key: ((orders.expected_delivery_date - orders.order_date)) DESC
  ->  Merge Join  (cost=28.59..50.75 rows=19 width=20)
        Merge Cond: (orders.order_id = order_lines.order_id)
        ->  Index Scan using pk_sales_orders on orders  (cost=0.29..2819.22 rows=73595 width=16)
        ->  Sort  (cost=28.30..28.35 rows=19 width=8)
              Sort Key: order_lines.order_id
              ->  Bitmap Heap Scan on order_lines  (cost=4.42..27.89 rows=19 width=8)
                    Recheck Cond: (quantity >= 250)
                    ->  Bitmap Index Scan on quantity  (cost=0.00..4.42 rows=19 width=0)
                          Index Cond: (quantity >= 250)

Bijna alles wordt nu met een index scan uitgevoerd. Al met al toch stukje sneller.


-- S7.3.C
--
-- Zou je de query ook heel anders kunnen schrijven om hem te versnellen?

Ik zie dat je eventueel iets met de JOIN zou moeten kunnen.
Opzich is Join dan wel sneller dan subquery, en een berekening voor een hele kolom gaat je kosten
Een view zou al helpen.
Ik heb getracht daar een index van te maken, maar helaas had dat geen effect op de cost


EXPLAIN		 SELECT
                    orders.order_id,
                    order_date,
                    salesperson_person_id AS verkoper,
                    (expected_delivery_date - order_date) AS levertijd,
                    quantity
                FROM orders
                         LEFT JOIN order_lines ON orders.order_id = order_lines.order_id
                WHERE quantity >= 250
                ORDER BY levertijd DESC;

Sort  (cost=51.16..51.20 rows=19 width=20)
  Sort Key: ((orders.expected_delivery_date - orders.order_date)) DESC
  ->  Merge Join  (cost=28.59..50.75 rows=19 width=20)
        Merge Cond: (orders.order_id = order_lines.order_id)
        ->  Index Scan using pk_sales_orders on orders  (cost=0.29..2819.22 rows=73595 width=16)
        ->  Sort  (cost=28.30..28.35 rows=19 width=8)
              Sort Key: order_lines.order_id
              ->  Bitmap Heap Scan on order_lines  (cost=4.42..27.89 rows=19 width=8)
                    Recheck Cond: (quantity >= 250)
                    ->  Bitmap Index Scan on quantity  (cost=0.00..4.42 rows=19 width=0)
                          Index Cond: (quantity >= 250)
