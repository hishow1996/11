from pathlib import Path
ROOT = Path(__file__).resolve().parents[1] / 'art' / 'runtime'
items = {
'landmark_city.svg': ('#ef6f61','#86d6e8','CITY LOOP','CITY'),
'landmark_rural.svg': ('#f4b86b','#74d0ad','FARM VALLEY','RURAL'),
'landmark_forest.svg': ('#397a68','#9fe3ff','FOREST LAKE','FOREST'),
'landmark_mountain.svg': ('#59627b','#d5dded','SNOW PASS','MOUNTAIN'),
'landmark_plains.svg': ('#d5a94d','#86d6e8','GOLDEN PLAINS','PLAINS'),
}
for filename, (accent, sky, title, subtitle) in items.items():
    svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="640" height="180" viewBox="0 0 640 180"><rect x="8" y="8" width="624" height="164" rx="22" fill="#211c37" stroke="{accent}" stroke-width="8"/><path d="M34 137h572" stroke="{sky}" stroke-width="4" opacity=".8"/><path d="M54 126l64-58 42 33 57-52 63 77" fill="none" stroke="{accent}" stroke-width="10" opacity=".9"/><circle cx="555" cy="58" r="22" fill="{sky}" opacity=".9"/><text x="320" y="75" text-anchor="middle" font-family="sans-serif" font-size="38" font-weight="700" fill="#fff1cf" letter-spacing="4">{title}</text><text x="320" y="119" text-anchor="middle" font-family="sans-serif" font-size="19" fill="{sky}" letter-spacing="7">{subtitle}  •  ANIME HAUL</text></svg>'''
    (ROOT/filename).write_text(svg, encoding='utf-8')
print(f'generated {len(items)} landmark signs')
