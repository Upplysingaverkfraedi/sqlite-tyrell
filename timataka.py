
import requests
import pandas as pd
import argparse
import re
import sqlite3
def parse_arguments():
    parser = argparse.ArgumentParser(description='Vinna með úrslit af tímataka.net.')
    parser.add_argument('--url', help='Slóð að vefsíðu með úrslitum.')
    parser.add_argument('--output', required=True,
                        help='Slóð að útgangsskrá til að vista niðurstöðurnar (CSV format).')
    parser.add_argument('--debug', action='store_true',
                        help='Vistar html í skrá til að skoða.')
    return parser.parse_args()

def valid_url(url):
    # regluleg segð sem sér til þess að url sé valid
    pattern = re.compile(r'^https?://(?:www\.)?timataka\.net/[\w-]+/urslit/\?race=\d+&cat=[a-z]+(?:&age=\d{4})?$')
    return bool(pattern.match(url))

def fetch_html(url):
    response = requests.get(url)
    if response.status_code == 200:
        return response.text
    else:
        print(f"Tókst ekki að sækja gögn af {url}")
        return None

def parse_html(html):
    # Regluleg segð sem skilar hvaða röð sem er í niðurstöðum
    row_pattern = re.compile(r'<tr>(.*?)</tr>', re.DOTALL)
    cell_pattern = re.compile(r'<td[^>]*>([^<]*)</td>')
    results = []
    # Finna allar raðir í HTML
    rows = row_pattern.findall(html)

    # Ítra yfir hverja og eina röð og finna gildi
    for row in rows:
        cells = cell_pattern.findall(row)
        if len(cells) >= 5:  # Gef mér að það séu að minnsta kosti 5 línur í töflu
            results.append({
                'Rank': cells[0].strip(),
                'Bib': cells[1].strip(),
                'Name': cells[2].strip(),
                'Time': cells[3].strip(),
                'Category': cells[4].strip(),
            })
    
    return results

def save_results(results, output_file):
    df = pd.DataFrame(results)
    df.to_csv(output_file, index=False)
    print(f"Niðurstöður vistaðar í {output_file}")
def insert_into_database(csv_file, db_file):
    # Tengjast gagnagrunninum
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()

    # Lesa CSV gögnin inn í Pandas gagnagrunn
    df = pd.read_csv(csv_file)

    # Setja gögnin í töfluna timataka í gagnagrunninum
    for index, row in df.iterrows():
        # Finna hlaupið í hlaup töflunni eða setja inn nýtt hlaup ef það er ekki til
        cursor.execute('''
            INSERT OR IGNORE INTO hlaup (nafn, upphaf)
            VALUES (?, ?)
        ''', (row['Category'], '2024-01-01 10:00:00'))  

        # Finna hlaupið sem var sett inn (ef það var nýtt)
        cursor.execute('''
            SELECT id FROM hlaup WHERE nafn = ?
        ''', (row['Category'],))
        hlaup_id = cursor.fetchone()[0]

        # Setja keppandann inn í timataka töfluna
        cursor.execute('''
            INSERT OR IGNORE INTO timataka (hlaup_id, nafn, timi, kyn)
            VALUES (?, ?, ?, ?)
        ''', (hlaup_id, row['Name'], row['Time'], 'Ótilgreint'))  

    # Vista breytingar og loka gagnagrunninum
    conn.commit()
    conn.close()

def main():
    args = parse_arguments()

    # Sjá til þess að url sé valid annars prenta út villumeldingu
    if not valid_url(args.url):
        print("Ógild slóð, vinsamlegast sláðu inn rétt úrslitaslóð.")
        return

    # Nái í HTML gögn
    html = fetch_html(args.url)
    if html is None:
        return

    # Parsea HTML gögn
    results = parse_html(html)

    # vista gögn í csv file
    save_results(results, args.output)

if __name__ == "__main__":
    main()
