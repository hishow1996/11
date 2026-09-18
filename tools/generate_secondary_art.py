from pathlib import Path
ROOT = Path(__file__).resolve().parents[1] / 'art' / 'runtime'
assets = {
'facility_fuel.svg': ('#ffd166','FUEL STOP'),
'facility_repair.svg': ('#74d0ad','SERVICE GARAGE'),
'traffic_car.svg': ('#6f9fe8','CAR'),
'traffic_van.svg': ('#ef6f61','VAN'),
'traffic_bus.svg': ('#f4b86b','BUS'),
'foliage_pine.svg': ('#397a68','PINE'),
'foliage_bush.svg': ('#74d0ad','BUSH'),
'mountain_ice.svg': ('#9fe3ff','ICE PASS'),
'road_tunnel.svg': ('#59627b','TUNNEL'),
'road_bridge.svg': ('#8c6048','BRIDGE'),
}
for filename,(accent,label) in assets.items():
    if filename.startswith('traffic_'):
        body='<rect x="80" y="55" width="480" height="170" rx="54" fill="#211c37" stroke="%s" stroke-width="12"/><rect x="130" y="80" width="150" height="70" rx="20" fill="#9fe3ff"/><rect x="360" y="80" width="150" height="70" rx="20" fill="#9fe3ff"/><circle cx="170" cy="235" r="34" fill="#211c37" stroke="#fff1cf" stroke-width="10"/><circle cx="470" cy="235" r="34" fill="#211c37" stroke="#fff1cf" stroke-width="10"/>' % accent
    elif filename.startswith('facility_'):
        body='<rect x="80" y="75" width="480" height="180" rx="18" fill="#211c37" stroke="%s" stroke-width="12"/><path d="M130 210V125h100v85M280 210v-65h95v65M430 210v-95h70v95" fill="none" stroke="#fff1cf" stroke-width="14"/><circle cx="180" cy="120" r="18" fill="%s"/>' % (accent,accent)
    elif filename == 'foliage_pine.svg':
        body='<path d="M320 35L185 230h78l-55 75h224l-55-75h78z" fill="%s" stroke="#211c37" stroke-width="12"/><rect x="288" y="285" width="64" height="70" fill="#8c6048" stroke="#211c37" stroke-width="10"/>' % accent
    elif filename == 'foliage_bush.svg':
        body='<circle cx="220" cy="210" r="95" fill="%s" stroke="#211c37" stroke-width="12"/><circle cx="360" cy="180" r="115" fill="%s" stroke="#211c37" stroke-width="12"/><circle cx="470" cy="220" r="82" fill="%s" stroke="#211c37" stroke-width="12"/>' % (accent,'#397a68',accent)
    else:
        body='<path d="M60 260L210 90l110 95L455 55l125 205z" fill="%s" stroke="#211c37" stroke-width="14"/><path d="M160 260l55-80 40 35 65-88 85 133" fill="none" stroke="#fff1cf" stroke-width="16" opacity=".9"/>' % accent
    svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="640" height="320" viewBox="0 0 640 320"><rect width="640" height="320" rx="24" fill="#86d6e8" opacity=".18"/>{body}<text x="320" y="300" text-anchor="middle" font-family="sans-serif" font-size="24" font-weight="700" fill="#fff1cf" letter-spacing="5">{label}</text></svg>'''
    (ROOT/filename).write_text(svg,encoding='utf-8')
print(f'generated {len(assets)} secondary assets')
