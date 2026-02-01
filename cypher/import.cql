-- Artysci
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/artysci.csv" AS row
MERGE (a:Artysta {artysta_id: row.artysta_id})
SET a.nazwa = row.nazwa, a.kraj = row.kraj, a.aktywny_od = row.aktywny_od, a.aktywny_do = row.aktywny_do;

-- Albumy i relacje CREATED oraz SIGNED_TO
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/albumy.csv" AS row
MERGE (al:Album {album_id: row.album_id})
SET al.tytul = row.tytul, al.rok = toInteger(row.rok)
WITH al,row
MATCH (a:Artysta {artysta_id: row.artysta_id})
MERGE (a)-[:CREATED]->(al)
WITH al,row
MATCH (w:Wytwornia {wytwornia_id: row.wytwornia_id})
MERGE (a)-[:SIGNED_TO]->(w);

-- Utwory i relacja CONTAINS
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/utwory.csv" AS row
MERGE (u:Utwor {utwor_id: row.utwor_id})
SET u.tytul = row.tytul, u.dlugosc = toInteger(row.dlugosc_sec), u.numer_w_albumie = toInteger(row.numer_w_albumie)
WITH u,row
MATCH (al:Album {album_id: row.album_id})
MERGE (al)-[:CONTAINS]->(u);

-- Gatunki muzyczne
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/gatunki.csv" AS row
MERGE (g:Gatunek {gatunek_id: row.gatunek_id})
SET g.nazwa = row.nazwa;

-- Wytwornie muzyczne
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/wytwornie.csv" AS row
MERGE (w:Wytwórnia {wytwornia_id: row.wytwornia_id})
SET w.nazwa = row.nazwa, w.kraj = row.kraj;

-- Wykonania PERFORMED i FEATURED_ON
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/wykonania.csv" AS row
MATCH (u:Utwor {utwor_id: row.utwor_id})
MATCH (a:Artysta {artysta_id: row.artysta_id})
CALL {
  WITH a,u,row
  WHERE row.rola = 'main'
  MERGE (a)-[:PERFORMED]->(u)
  RETURN 1
  UNION
  WITH a,u,row
  WHERE row.rola = 'featured'
  MERGE (a)-[:FEATURED_ON]->(u)
  RETURN 1
}
RETURN count(*) AS loaded;

-- Gatunki utworow IN_GENRE
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/utwor_gatunek.csv" AS row
MATCH (u:Utwor {utwor_id: row.utwor_id})
MATCH (g:Gatunek {gatunek_id: row.gatunek_id})
MERGE (u)-[:IN_GENRE]->(g);

-- Wspolprace COLLABORATED_WITH
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/WeronikaSieniawska/Projekt_ko-cowy_neo4j/main/dane/wspolprace.csv" AS row
MATCH (a:Artysta {artysta_id: row.artysta_id_a})
MATCH (b:Artysta {artysta_id: row.artysta_id_b})
MERGE (a)-[r:COLLABORATED_WITH]-(b)
SET r.rok_pierwszej_wspolpracy = toInteger(row.rok_pierwszej_wspolpracy), r.notatki = row.notatki;
