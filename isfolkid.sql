-- 1. Hversu margar aðalpersónur eru í bókabálkinum?
WITH RECURSIVE split(characters, str) AS (
    SELECT
        '',
        characters||','
    FROM
        books
    UNION ALL SELECT
        TRIM(substr(str, 0, instr(str, ','))),
        substr(str, instr(str, ',')+1)
    FROM split
    WHERE str != ''
)
SELECT
    COUNT(DISTINCT characters)
FROM split
WHERE characters != '';


-- 2. Hversu margar persónur eru í hverri bók?
SELECT 
    is_title, 
    LENGTH(characters) - LENGTH(REPLACE(characters, ',', '')) + 1 AS total_characters
FROM 
    books;


-- 3. Hversu oft kemur Þengill fyrir í bókunum?
WITH RECURSIVE split(characters, str) AS (
    SELECT
        '',
        characters||','
    FROM
        books
    UNION ALL SELECT
        TRIM(substr(str, 0, instr(str, ','))),
        substr(str, instr(str, ',')+1)
    FROM split
    WHERE str != ''
)
SELECT
    COUNT(*)
FROM split
WHERE characters = 'Þengill';

-- 4. Hvað eru margir af Paladín ættinni? 
SELECT COUNT(*) AS paladin_count
FROM family
WHERE name LIKE '%Paladín%';

-- 5. Hversu algengur er illi arfurinn af þeim sem eru útvalin? (útkoma í prósentum) 

SELECT 
    (COUNT(CASE WHEN chosen_one = 'evil' THEN 1 END) * 100.0 / COUNT(chosen_one)) AS evil_percentage
FROM family
WHERE chosen_one IS NOT NULL;

-- 6. Hver er fæðingartíðni kvenna í bókabálkinum?
SELECT AVG(child_count) AS average_children_per_mother
FROM (
    SELECT mom, COUNT(ID) AS child_count
    FROM family
    WHERE mom IS NOT NULL
    GROUP BY mom
) AS subquery;

-- 7. Hvað er Ísfólkið margar blaðsíður samanlagt?
SELECT SUM(pages) AS total_pages
FROM books;

-- 8.Hvað er meðallengd hvers þáttar af Ískisum?
SELECT AVG(length) AS average_length
FROM storytel_iskisur;

