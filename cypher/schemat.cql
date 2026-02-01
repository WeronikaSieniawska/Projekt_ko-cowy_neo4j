// Węzły: Artysta, Album, Utwór, Gatunek_muzyczny, Wytwórnia

CREATE CONSTRAINT artysta_id IF NOT EXISTS
FOR (a:Artysta) REQUIRE a.id IS UNIQUE;

CREATE CONSTRAINT album_id IF NOT EXISTS
FOR (a:Album) REQUIRE a.id IS UNIQUE;

CREATE CONSTRAINT utwor_id IF NOT EXISTS
FOR (u:Utwor) REQUIRE u.id IS UNIQUE;

CREATE CONSTRAINT gatunek_id IF NOT EXISTS
FOR (g:Gatunek_muzyczny) REQUIRE g.id IS UNIQUE;

CREATE CONSTRAINT wytwornia_id IF NOT EXISTS
FOR (w:Wytwornia) REQUIRE w.id IS UNIQUE;
