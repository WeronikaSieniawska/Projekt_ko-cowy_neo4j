-- Wytwornie muzyczne
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/wytwornie.csv" AS row

WITH row, TRIM(row.wytwornia_id) AS wytworniaID
WHERE wytworniaID <> ""

MERGE (w:Wytwórnia {wytwornia_id: wytworniaID})
SET w.nazwa = row.nazwa,
    w.kraj = row.kraj;

-- Gatunki muzyczne
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/gatunki.csv" AS row

WITH row, TRIM(row.gatunek_id) AS gatunekID
WHERE gatunekID <> ""

MERGE (g:Gatunek {gatunek_id: gatunekID})
SET g.nazwa = row.nazwa;

-- Artysci
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/artysci.csv" AS row

WITH row, TRIM(row.artysta_id) AS artystaID
WHERE artystaID <> ""

MERGE (a:Artysta {artysta_id: artystaID})
SET a.nazwa = row.nazwa,
    a.kraj = row.kraj,
    a.aktywny_od = row.aktywny_od,
    a.aktywny_do = row.aktywny_do;
;

-- Albumy i relacje CREATED oraz SIGNED_TO
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/albumy.csv" AS row

WITH row,
     TRIM(row.album_id) AS albumID,
     TRIM(row.artysta_id) AS artystaID,
     TRIM(row.wytwornia_id) AS wytworniaID

MERGE (al:Album {album_id: albumID})
SET al.tytul = row.tytul,
    al.rok = toInteger(row.rok)

WITH al, artystaID, wytworniaID
MATCH (a:Artysta {artysta_id: artystaID})
MERGE (a)-[:CREATED]->(al)

WITH al, wytworniaID, a
MATCH (w:Wytwórnia {wytwornia_id: wytworniaID})
MERGE (a)-[:SIGNED_TO]->(w);

-- Utwory i relacja CONTAINS
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/utwory.csv" AS row

WITH row, TRIM(row.utwor_id) AS utworID
WHERE utworID <> ""

MERGE (u:Utwór {utwor_id: utworID})
SET u.tytul = row.tytul,
    u.dlugosc = toInteger(row.dlugosc),
    u.numer_w_albumie = toInteger(row.numer_w_albumie)

WITH u, row
MATCH (al:Album {album_id: row.album_id})
MERGE (al)-[:CONTAINS]->(u);

-- Wykonania PERFORMED i FEATURED_ON
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/wykonania.csv" AS row

WITH row,
     TRIM(row.utwor_id) AS utworID,
     TRIM(row.artysta_id) AS artystaID
WHERE utworID <> "" AND artystaID <> ""

MATCH (u:Utwór {utwor_id: utworID})
MATCH (a:Artysta {artysta_id: artystaID})

FOREACH (_ IN CASE WHEN row.rola = 'main' THEN [1] ELSE [] END |
    MERGE (a)-[:PERFORMED]->(u)
)

FOREACH (_ IN CASE WHEN row.rola = 'featured' THEN [1] ELSE [] END |
    MERGE (a)-[:FEATURED_ON]->(u)
);

-- Gatunki utworow  IN_GENRE
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/utwor_gatunek.csv" AS row

WITH row,
     TRIM(row.utwor_id) AS utworID,
     TRIM(row.gatunek_id) AS gatunekID
WHERE utworID <> "" AND gatunekID <> ""

MATCH (u:Utwór {utwor_id: utworID})
MATCH (g:Gatunek {gatunek_id: gatunekID})
MERGE (u)-[:IN_GENRE]->(g);

-- Wspolprace COLLABORATED_WITH
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/wspolprace.csv" AS row

WITH row,
     TRIM(row.artysta_id_a) AS artystaA,
     TRIM(row.artysta_id_b) AS artystaB
WHERE artystaA <> "" AND artystaB <> ""

MATCH (a:Artysta {artysta_id: artystaA})
MATCH (b:Artysta {artysta_id: artystaB})

MERGE (a)-[r:COLLABORATED_WITH]-(b)
SET r.rok_pierwszej_wspolpracy = toInteger(row.rok_pierwszej_wspolpracy),
    r.notatki = row.notatki;