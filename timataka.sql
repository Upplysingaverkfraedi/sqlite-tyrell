-- Búa til töflu fyrir hlaup
CREATE TABLE IF NOT EXISTS hlaup (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    upphaf DATETIME NOT NULL,
    endir DATETIME NOT NULL,
    nafn TEXT NOT NULL,
    fjoldi INTEGER,
    UNIQUE(nafn) -- til að taka ekki sama hlaup tvisvar
);

-- Búa til töflu fyrir timataka
CREATE TABLE IF NOT EXISTS timataka (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hlaup_id INTEGER NOT NULL,
    nafn TEXT NOT NULL,
    timi TIME,
    kyn TEXT,
    aldur INTEGER,
    UNIQUE(hlaup_id, nafn), -- til að taka ekki sama nafn tvisvar í sama hlaupi
    FOREIGN KEY(hlaup_id) REFERENCES hlaup(id)
);

-- Sannreyna hvort fjöldi keppenda í hlaup sé sá sami og í timataka
SELECT h.nafn, h.fjoldi AS "Fjöldi skráður", COUNT(t.id) AS "Fjöldi í timataka"
FROM hlaup h
LEFT JOIN timataka t ON h.id = t.hlaup_id
GROUP BY h.id
HAVING COUNT(t.id) != h.fjoldi;