-- PODSTAWOWE ZAPYTANIA

-- 1. Wszystkie albumy danego artysty
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:CREATED]->(al:Album)
RETURN al;

-- 2. Wszystkie utwory wykonane przez artyste
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:PERFORMED]->(u:Utwór)
RETURN u;

-- 3. Wszystkie utwory, na których artysta wystąpił gościnnie (featured)
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:FEATURED_ON]->(u:Utwór)
RETURN u;

-- 4. Wszystkie utwory artysty
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:PERFORMED|FEATURED_ON]->(u:Utwór)
RETURN u;

-- 5. Albumy i utwory artysty
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:CREATED]->(al:Album)-[:CONTAINS]->(u:Utwór)
RETURN al, u;


-- WSPOLPRACE MIEDZY ARTYSTAMI

-- 6. Bezposrednie wspolprace artysty
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:COLLABORATED_WITH]-(b:Artysta)
RETURN DISTINCT b;

-- 7. Siec wspolpracy artysty (do 3 stopni oddalenia)
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:COLLABORATED_WITH*1..3]-(b:Artysta)
WHERE a <> b
RETURN DISTINCT b;

-- 8. Liczba relacji wspolpracy
MATCH (a:Artysta)-[:COLLABORATED_WITH]-()
RETURN a.nazwa AS artysta, count(*) AS liczba_wspolprac
ORDER BY liczba_wspolprac DESC;

-- 9. Najkrotsza sciezka wspolpracy miedzy dwoma artystami
MATCH p = shortestPath(
  (a:Artysta {nazwa: 'Silver Echo'})-[:COLLABORATED_WITH*]-(b:Artysta {nazwa: 'Golden Strings'})
)
RETURN p;

-- GATUNKI I REKOMENDACJE

-- 10. Wszystkie utwory danego gatunku
MATCH (u:Utwór)-[:IN_GENRE]->(g:Gatunek {nazwa: 'Elektronika'})
RETURN u;

-- 11. Artysci wykonujacy utwory w danym gatunku
MATCH (a:Artysta)-[:PERFORMED]->(u:Utwór)-[:IN_GENRE]->(g:Gatunek {nazwa: 'Elektronika'})
RETURN DISTINCT a;

-- 12. Rekomendacje artystow na podstawie wspolnych gatunkow
MATCH (a1:Artysta)-[PERFORMED]->(u:Utwór)-[IN_GENRE]->(g:Gatunek)<-[:IN_GENRE]-(u2:Utwór)<-[:PERFORMED]-(a2:Artysta)
WHERE a1 <> a2
RETURN a1.nazwa AS Artysta1, a2.nazwa AS Artysta2, count(g) AS WspolneGatunki
ORDER BY WspolneGatunki DESC
LIMIT 10

-- 13. Gatunki najczesciej wykonywane przez artystow wspolpracujacych ze soba
MATCH (a:Artysta)-[:COLLABORATED_WITH]-(b:Artysta)
MATCH (b)-[:PERFORMED]->(u:Utwór)-[:IN_GENRE]->(g:Gatunek)
RETURN a.nazwa AS artysta, COLLECT(DISTINCT g.nazwa) AS gatunki
ORDER BY SIZE(gatunki) DESC;

-- WYTWORNIE

-- 14. Artysci podpisani z daną wytwornia (Starline Records)
MATCH (a:Artysta)-[:SIGNED_TO]->(w:Wytwórnia {nazwa: 'Starline Records'})
RETURN a;

-- 15. Wytwornie, z ktorymi wspolpracowal artysta
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:SIGNED_TO]->(w:Wytwórnia)
RETURN w;

-- 16. Wytwornie o najwiekszej roznorodnosci gatunkowej
MATCH (w:Wytwórnia)<-[:SIGNED_TO]-(a:Artysta)
MATCH (a)-[:CREATED]->(:Album)-[:CONTAINS]->(:Utwór)-[:IN_GENRE]->(g:Gatunek)
RETURN w.nazwa AS wytwornia, COUNT(DISTINCT g) AS liczba_gatunkow
ORDER BY liczba_gatunkow DESC;

-- ZAPYTANIA ANALITYCZNE

-- 17. Najpopularniejsze gatunki (liczba utworow)
MATCH (u:Utwór)-[:IN_GENRE]->(g:Gatunek)
RETURN g.nazwa AS gatunek, count(u) AS liczba_utworow
ORDER BY liczba_utworow DESC;

-- 18. Artysci z najwieksza liczba utworow (PERFORMED)
MATCH (a:Artysta)-[:PERFORMED]->(u:Utwór)
RETURN a.nazwa AS artysta, count(u) AS liczba_utworow
ORDER BY liczba_utworow DESC;

-- 19. Albumy z najwieksza liczba utworow
MATCH (al:Album)-[:CONTAINS]->(u:Utwór)
RETURN al.tytul AS album, count(u) AS liczba_utworow
ORDER BY liczba_utworow DESC;

-- 20. Utwory z gościnnymi wystepami
MATCH (gosc:Artysta)-[:FEATURED_ON]->(u:Utwór)
MATCH (gosc)-[:PERFORMED]->(u2:Utwór)
WITH u.tytul AS utwor, collect(DISTINCT u2.tytul) AS goscinnie
RETURN utwor, goscinnie
ORDER BY utwor;

-- 21. Artysci, ktorzy wspolpracowali z najwieksza liczba innych artystow
MATCH (a:Artysta)-[:COLLABORATED_WITH]-(b:Artysta)
RETURN a.nazwa AS artysta, count(DISTINCT b) AS liczba_wspolprac
ORDER BY liczba_wspolprac DESC;

-- 22. Utwory artysty wraz z gatunkami
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:PERFORMED]->(u:Utwór)-[:IN_GENRE]->(g:Gatunek)
RETURN u.tytul AS utwor, g.nazwa AS gatunek;

-- 23. Artysci, ktorzy najczesciej wspolpracuja z artystami z innych gatunkow
MATCH (a:Artysta)-[:PERFORMED]->(u1:Utwór)-[:IN_GENRE]->(g1:Gatunek)
MATCH (a)-[:COLLABORATED_WITH]-(b:Artysta)
MATCH (b)-[:PERFORMED]->(u2:Utwór)-[:IN_GENRE]->(g2:Gatunek)
WHERE g1 <> g2
RETURN a.nazwa AS artysta, COUNT(DISTINCT b) AS cross_genre_collabs
ORDER BY cross_genre_collabs DESC;

-- 24. Najbardziej wplywowe utwory (najwiecej powiazan)
MATCH (u:Utwór)
OPTIONAL MATCH (u)<-[:PERFORMED]-(a1:Artysta)
OPTIONAL MATCH (u)<-[:FEATURED_ON]-(a2:Artysta)
OPTIONAL MATCH (u)-[:IN_GENRE]->(g:Gatunek)
RETURN u.tytul AS utwor,
       COUNT(DISTINCT a1) + COUNT(DISTINCT a2) + COUNT(DISTINCT g) AS powiazania
ORDER BY powiazania DESC;

-- 25. Wytwornie z najwieksza liczba artystow
MATCH (a:Artysta)-[:SIGNED_TO]->(w:Wytwórnia)
WITH w, count(a) AS liczba_artystow
ORDER BY liczba_artystow DESC
LIMIT 1
RETURN w.nazwa AS wytwornia, liczba_artystow

-- CRUD

-- 26. Dodanie nowego artysty wraz z automatycznym przypisaniem do wytworni
MATCH (w:Wytwórnia {nazwa: "Starline Records"})
CREATE (a:Artysta {
    artysta_id: "A1200",
    nazwa: "Crystal Wave",
    kraj: "Islandia",
    aktywny_od: 2018
})
MERGE (a)-[:SIGNED_TO]->(w);

-- 27. Dodanie albumu i automatyczne powiazanie go z artysta oraz utworami
MATCH (a:Artysta {nazwa: "Crystal Wave"})
CREATE (al:Album {
    album_id: "AL1200",
    tytul: "Frozen Echoes",
    rok: 2025
})
MERGE (a)-[:CREATED]->(al)
WITH al
UNWIND [
    {id:"U1201", t:"Glacier Pulse", d:210, nr:1},
    {id:"U1202", t:"Northern Lights", d:245, nr:2}
] AS utw
CREATE (u:Utwór {
    utwor_id: utw.id,
    tytul: utw.t,
    dlugosc: utw.d,
    numer_w_albumie: utw.nr
})
MERGE (al)-[:CONTAINS]->(u);

-- 28. Dodanie wspolpracy miedzy artystami tylko wtedy, gdy jeszcze nie istnieje
MATCH (a1:Artysta {nazwa: "Silver Echo"})
MATCH (a2:Artysta {nazwa: "Crystal Wave"})
MERGE (a1)-[r:COLLABORATED_WITH]-(a2)
ON CREATE SET r.rok_pierwszej_wspolpracy = 2025,
              r.notatki = "Pierwsza współpraca na albumie Frozen Echoes";

-- 29. Aktualizacja kraju artysty tylko jesli jest nieznany
MATCH (a:Artysta {nazwa: "Crystal Wave"})
WHERE a.kraj IS NULL OR a.kraj = ""
SET a.kraj = "Islandia";

-- 30. Zmiana gatunku utworu
MATCH (u:Utwór {tytul: "Northern Lights"})-[r:IN_GENRE]->(:Gatunek)
DELETE r
WITH u
MATCH (g:Gatunek {nazwa: "Elektronika"})
MERGE (u)-[:IN_GENRE]->(g);

-- 31. Usuniecie wszystkich wspolprac artysty, ale bez usuwania artysty
MATCH (:Artysta {nazwa: "Silver Echo"})-[r:COLLABORATED_WITH]-()
DELETE r;

 -- 32. Usuniecie relacji PERFORMED tylko dla utworow krotszych niż 2 minuty
MATCH (a:Artysta)-[r:PERFORMED]->(u:Utwór)
WHERE u.dlugosc < 120
DELETE r;

-- 33. Przeniesienie artysty do innej wytworni
MATCH (a:Artysta {nazwa: "Silver Echo"})-[old:SIGNED_TO]->(:Wytwórnia)
DELETE old
WITH a
MATCH (w:Wytwórnia {nazwa: "Starline Records"})
MERGE (a)-[:SIGNED_TO]->(w);

-- 34. Zastapienie goscinnego wystepu pelnym wykonaniem
MATCH (a:Artysta {nazwa: "Silver Echo"})-[f:FEATURED_ON]->(u:Utwór)
DELETE f
MERGE (a)-[:PERFORMED]->(u);

-- 35. Usuniecie artystow, ktorzy nie maja zadnych relacji
MATCH (a:Artysta)
WHERE NOT (a)-[]->()
DELETE a
