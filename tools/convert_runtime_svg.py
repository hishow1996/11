from pathlib import Path
import cairosvg

ROOT = Path(__file__).resolve().parents[1]
for svg in sorted((ROOT / 'art/runtime').glob('*.svg')):
    png = svg.with_suffix('.png')
    cairosvg.svg2png(url=str(svg), write_to=str(png), output_width=512, output_height=512)
    print(f'{svg.name} -> {png.name}')

script = ROOT / 'scripts/main_3d.gd'
text = script.read_text()
text = text.replace('.svg")', '.png")')
script.write_text(text)
