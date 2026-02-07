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

-- 7. Siec wspolpracy do 3 stopni
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:COLLABORATED_WITH*1..3]-(b:Artysta)
WHERE a <> b
RETURN DISTINCT b;

-- 8. Liczba relacji wspolpracy
MATCH (a:Artysta)-[:COLLABORATED_WITH]-()
RETURN a.nazwa AS artysta, count(*) AS liczba_wspolprac
ORDER BY liczba_wspolprac DESC;

-- 9. Najkrotsza sciezka wspolpracy miedzy dwoma artystami
MATCH p = shortestPath(
  (a:Artysta {nazwa: 'Silver Echo'})-[:COLLABORATED_WITH*]-(b:Artysta {nazwa: 'Urban Flow'})
)
RETURN p;

-- GATUNKI I REKOMENDACJE

-- 10. Wszystkie utwory danego gatunku
MATCH (u:Utwór)-[:IN_GENRE]->(g:Gatunek {nazwa: 'Elektronika'})
RETURN u;

-- 11. Artysci wykonujscy utwory w danym gatunku
MATCH (a:Artysta)-[:PERFORMED]->(u:Utwór)-[:IN_GENRE]->(g:Gatunek {nazwa: 'Elektronika'})
RETURN DISTINCT a;

-- 12. Rekomendacje artystow na podstawie wspolnych gatunkow
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:PERFORMED|FEATURED_ON]->(:Utwór)-[:IN_GENRE]->(g:Gatunek)
MATCH (inny:Artysta)-[:PERFORMED|FEATURED_ON]->(:Utwór)-[:IN_GENRE]->(g)
WHERE inny <> a
RETURN inny, count(DISTINCT g) AS wspolne_gatunki
ORDER BY wspolne_gatunki DESC;

-- WYTWORNIE

-- 13. Artysci podpisani z daną wytwornia (Starline Records)
MATCH (a:Artysta)-[:SIGNED_TO]->(w:Wytwórnia {nazwa: 'Starline Records'})
RETURN a;

-- 14. Wytwornie, z ktorymi wspolpracowal artysta
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:SIGNED_TO]->(w:Wytwórnia)
RETURN w;

-- ZAPYTANIA ANALITYCZNE

-- 15. Najpopularniejsze gatunki (liczba utworow)
MATCH (u:Utwór)-[:IN_GENRE]->(g:Gatunek)
RETURN g.nazwa AS gatunek, count(u) AS liczba_utworow
ORDER BY liczba_utworow DESC;

-- 16. Artysci z najwieksza liczba utworow (PERFORMED)
MATCH (a:Artysta)-[:PERFORMED]->(u:Utwór)
RETURN a.nazwa AS artysta, count(u) AS liczba_utworow
ORDER BY liczba_utworow DESC;

-- 17. Albumy z najwieksza liczba utworow
MATCH (al:Album)-[:CONTAINS]->(u:Utwór)
RETURN al.tytul AS album, count(u) AS liczba_utworow
ORDER BY liczba_utworow DESC;

-- 18. Utwory z gościnnymi wystepami
MATCH (u:Utwór)<-[:FEATURED_ON]-(a:Artysta)
RETURN u, collect(a.nazwa) AS goscie;

-- 19. Artysci, ktorzy wspolpracowali z najwieksza liczba innych artystow
MATCH (a:Artysta)-[:COLLABORATED_WITH]-(b:Artysta)
RETURN a.nazwa AS artysta, count(DISTINCT b) AS liczba_partnerow
ORDER BY liczba_partnerow DESC;

-- 20. Utwory artysty wraz z gatunkami
MATCH (a:Artysta {nazwa: 'Silver Echo'})-[:PERFORMED]->(u:Utwór)-[:IN_GENRE]->(g:Gatunek)
RETURN u.tytul AS utwor, g.nazwa AS gatunek;
