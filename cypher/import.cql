-- ARTYŚCI
LOAD CSV WITH HEADERS FROM 'LINK/artysci.csv' AS row
CREATE (:Artysta {
  id: row.artystaId,
  nazwa: row.nazwa,
  kraj: row.kraj,
  czas_aktywnosci: row.czas_aktywnosci
});

-- ALBUMY
LOAD CSV WITH HEADERS FROM 'LINK/albumy.csv' AS row
CREATE (:Album {
  id: row.albumId,
  tytul: row.tytul,
  rok: toInteger(row.rok)
});

-- UTWORY
LOAD CSV WITH HEADERS FROM 'LINK/utwory.csv' AS row
CREATE (:Utwor {
  id: row.utworId,
  tytul: row.tytul,
  dlugosc: toInteger(row.dlugosc),
  numer_w_albumie: toInteger(row.numer_w_albumie)
});

-- GATUNKI
LOAD CSV WITH HEADERS FROM 'LINK/gatunki.csv' AS row
CREATE (:Gatunek_muzyczny {
  id: row.gatunekId,
  nazwa: row.nazwa
});

-- WYTWÓRNIE
LOAD CSV WITH HEADERS FROM 'LINK/wytwornie.csv' AS row
CREATE (:Wytwornia {
  id: row.wytworniaId,
  nazwa: row.nazwa,
  kraj: row.kraj
});



-- Artysta → Album
LOAD CSV WITH HEADERS FROM 'LINK/artysta_stworzyl_album.csv' AS row
MATCH (a:Artysta {id: row.artystaId})
MATCH (al:Album {id: row.albumId})
CREATE (a)-[:STWORZYL]->(al);

-- Album → Utwór
LOAD CSV WITH HEADERS FROM 'LINK/album_zawiera_utwor.csv' AS row
MATCH (al:Album {id: row.albumId})
MATCH (u:Utwor {id: row.utworId})
CREATE (al)-[:ZAWIERA]->(u);

-- Artysta → Utwór (wykonał)
LOAD CSV WITH HEADERS FROM 'LINK/artysta_wykonal_utwor.csv' AS row
MATCH (a:Artysta {id: row.artystaId})
MATCH (u:Utwor {id: row.utworId})
CREATE (a)-[:WYKONAL]->(u);

-- Artysta → Utwór (gościnnie)
LOAD CSV WITH HEADERS FROM 'LINK/artysta_wystapil_goscinnie.csv' AS row
MATCH (a:Artysta {id: row.artystaId})
MATCH (u:Utwor {id: row.utworId})
CREATE (a)-[:WYSTAPIL_GOSCINNIE]->(u);

-- Artysta ↔ Artysta (współpraca)
LOAD CSV WITH HEADERS FROM 'LINK/artysci_wspolpracowali.csv' AS row
MATCH (a1:Artysta {id: row.artystaId1})
MATCH (a2:Artysta {id: row.artystaId2})
CREATE (a1)-[:WSPOLPRACOWAL_Z]->(a2);

-- Utwór → Gatunek
LOAD CSV WITH HEADERS FROM 'LINK/utwor_w_gatunku.csv' AS row
MATCH (u:Utwor {id: row.utworId})
MATCH (g:Gatunek_muzyczny {id: row.gatunekId})
CREATE (u)-[:W_GATUNKU]->(g);

-- Artysta → Wytwórnia
LOAD CSV WITH HEADERS FROM 'LINK/artysta_podpisal_z_wytwornia.csv' AS row
MATCH (a:Artysta {id: row.artystaId})
MATCH (w:Wytwornia {id: row.wytworniaId})
CREATE (a)-[:PODPISAL_Z]->(w);
