-- PODSTAWOWE ZAPYTANIA – POWIĄZANIA ARTYSTA–ALBUM–UTWÓR

-- 1. Wszystkie albumy danego artysty
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:STWORZYL]->(al:Album)
RETURN al;

-- 2. Wszystkie utwory wykonane przez artystę
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:WYKONAL]->(u:Utwor)
RETURN u;

-- 3. Wszystkie utwory, na których artysta wystąpił gościnnie
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:WYSTAPIL_GOSCINNIE]->(u:Utwor)
RETURN u;

-- 4. Wszystkie utwory artysty (wykonane + gościnne)
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:WYKONAL|WYSTAPIL_GOSCINNIE]->(u:Utwor)
RETURN u;

-- 5. Albumy i utwory artysty – pełna ścieżka
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:STWORZYL]->(al:Album)-[:ZAWIERA]->(u:Utwor)
RETURN al, u;


-- WSPÓŁPRACE MIĘDZY ARTYSTAMI

-- 6. Bezpośrednie współprace artysty
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:WSPOLPRACOWAL_Z]-(b:Artysta)
RETURN b;

-- 7. Sieć współprac do 3 stopni
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:WSPOLPRACOWAL_Z*1..3]-(b:Artysta)
WHERE a <> b
RETURN DISTINCT b;

-- 8. Najbardziej „połączeni” artyści
MATCH (a:Artysta)-[:WSPOLPRACOWAL_Z]-()
RETURN a.nazwa AS artysta, count(*) AS liczba_wspolprac
ORDER BY liczba_wspolprac DESC;

-- 9. Najkrótsza ścieżka współprac między dwoma artystami
MATCH p = shortestPath(
  (a:Artysta {nazwa: 'Silver Echo'})-[:WSPOLPRACOWAL_Z*]-(b:Artysta {nazwa: 'Urban Flow'})
)
RETURN p;

-- GATUNKI I REKOMENDACJE

-- 10. Wszystkie utwory danego gatunku
MATCH (u:Utwor)-[:W_GATUNKU]->(g:Gatunek_muzyczny {nazwa: 'Elektronika'})
RETURN u;

-- 11. Artyści wykonujący utwory w danym gatunku
MATCH (a:Artysta)-[:WYKONAL]->(u:Utwor)-[:W_GATUNKU]->(g:Gatunek_muzyczny {nazwa: 'Elektronika'})
RETURN DISTINCT a;

-- 12. Rekomendacje artystów na podstawie wspólnych gatunków
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:WYKONAL|WYSTAPIL_GOSCINNIE]->(:Utwor)-[:W_GATUNKU]->(g)
MATCH (inny:Artysta)-[:WYKONAL|WYSTAPIL_GOSCINNIE]->(:Utwor)-[:W_GATUNKU]->(g)
WHERE inny <> a
RETURN inny, count(DISTINCT g) AS wspolne_gatunki
ORDER BY wspolne_gatunki DESC;


-- WYTWÓRNIE

-- 13. Artyści podpisani z daną wytwórnią
MATCH (a:Artysta)-[:PODPISAL_Z]->(w:Wytwornia {nazwa: 'Starline Records'})
RETURN a;

-- 14. Wytwórnie, z którymi współpracował artysta
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:PODPISAL_Z]->(w:Wytwornia)
RETURN w;


-- ZAPYTANIA ANALITYCZNE

-- 15. Najpopularniejsze gatunki (liczba utworów)
MATCH (u:Utwor)-[:W_GATUNKU]->(g:Gatunek_muzyczny)
RETURN g.nazwa AS gatunek, count(u) AS liczba_utworow
ORDER BY liczba_utworow DESC;

-- 16. Artyści z największą liczbą utworów
MATCH (a:Artysta)-[:WYKONAL]->(u:Utwor)
RETURN a.nazwa AS artysta, count(u) AS liczba_utworow
ORDER BY liczba_utworow DESC;

-- 17. Albumy z największą liczbą utworów
MATCH (al:Album)-[:ZAWIERA]->(u:Utwor)
RETURN al.tytul AS album, count(u) AS liczba_utworow
ORDER BY liczba_utworow DESC;

-- 18. Utwory z gościnnymi występami
MATCH (a:Artysta)-[:WYSTAPIL_GOSCINNIE]->(u:Utwor)
RETURN u, collect(a.nazwa) AS goscie;

-- 19. Artyści, którzy współpracowali z największą liczbą innych artystów
MATCH (a:Artysta)-[:WSPOLPRACOWAL_Z]-(b:Artysta)
RETURN a.nazwa AS artysta, count(b) AS liczba_partnerow
ORDER BY liczba_partnerow DESC;

-- 20. Utwory artysty wraz z gatunkami
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:WYKONAL]->(u:Utwor)-[:W_GATUNKU]->(g)
RETURN u.tytul AS utwor, g.nazwa AS gatunek;
