-- Liður 1

CREATE TABLE IF NOT EXISTS names (
    name varchar(20),
    year int,
    frequency int,
    type text
);

CREATE TABLE IF NOT EXISTS temp_table (
    name varchar(20),
    year int,
    frequency int
);

.mode csv

.import data/first_names_freq.csv temp_table

INSERT INTO names(name, year, frequency, type) SELECT name, year, frequency, "eiginnafn" FROM temp_table;

DELETE FROM temp_table;

.import data/middle_names_freq.csv temp_table

INSERT INTO names(name, year, frequency, type) SELECT name, year, frequency, "millinafn" FROM temp_table;

DROP TABLE temp_table;

-- Liður 2
-- 2.1. Hvaða hópmeðlimur á algengasta eiginnafnið?

SELECT name, SUM(frequency) AS total_frequency
FROM names
WHERE name IN ('Þórdís', 'Ingvar', 'Logi') AND type="eiginnafn"
GROUP BY name
ORDER BY total_frequency DESC
LIMIT 1;
-- Algengasta eiginnafnið er Þórdís

-- 2.2. Hvenær voru öll nöfnin vinsælust?
SELECT name, year, MAX(frequency) AS highest_frequency
FROM names
WHERE name IN ('Þórdís', 'Ingvar', 'Logi') AND type="eiginnafn"
GROUP BY name 
ORDER BY name, highest_frequency DESC;
-- Ingvar var vinsælast 1973 með 18 manns, Logi vinsælast 1995 með 6 og Þórdís vinsælast 1992 með 26. 


-- Hvenær komu þau fyrst fram?
SELECT name, MIN(year) AS first_appearance
FROM names
WHERE name IN ('Þórdís', 'Ingvar', 'Logi')
GROUP BY name
ORDER BY first_appearance;
-- Þórdís kom fram 1908, Logi 1928 og Ingvar 1913. 
); 
