#!/usr/bin/env python3
"""Export the approved icon and original Game Center badges matching the game's vector symbols.
Dependencies: Pillow, CairoSVG. The app icon source is lossless WebP encoded as text so
it can be maintained by the connected repository API without binary corruption.
"""
import base64, hashlib, html, io, json, math, re
from pathlib import Path
import cairosvg
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/gamecenter/images'
INK='#426658'; PAPER='#ffffff'
COLORS={'Progresso':'#c3dccb','Costruzione':'#c9dfe9','Combattimento':'#ebbdc3','Laboratorio':'#d9cdeb','Modalità':'#efe0b7','Percorsi':'#bbddd5'}
# Original pictograms share the same rounded strokes and motifs as the game's ICO library.
MOTIFS={
'wave':'<path d="M3 7q3-5 6 0t6 0 6 0 M3 13q3-5 6 0t6 0 6 0 M3 19q3-5 6 0t6 0 6 0"/>',
'book':'<path d="M5 4h11a3 3 0 0 1 3 3v13H8a3 3 0 0 1-3-3z M5 17a3 3 0 0 1 3-3h11 M9 7h6 M9 10h6"/>',
'rings':'<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><path d="M12 9v6 M9 12h6"/>',
'build':'<path d="M3 20h18 M5 20V11h5v9 M10 20V5h5v15 M15 20V9h4v11"/>',
'pencil':'<path d="M4 20l1-4L16 5a2.1 2.1 0 0 1 3 3L8 19z M14 7l3 3 M5 16l3 3"/>',
'eraser':'<path d="M7 20h12 M5 15l9-9a2 2 0 0 1 3 0l3 3a2 2 0 0 1 0 3l-7 7H8z M12.5 7.5l5 5"/>',
'crown':'<path d="M4 6l4 5 4-7 4 7 4-5-2 13H6z M7 16h10"/>',
'shield':'<path d="M12 3l8 3v6c0 5-8 9-8 9s-8-4-8-9V6z M8 12l3 3 5-6"/>',
'flask':'<path d="M9 3h6 M10 3v7l-5 8q-1 3 2 3h10q3 0 2-3l-5-8V3 M8 15h8"/>',
'heal':'<path d="M9 4h6v5h5v6h-5v5H9v-5H4V9h5z"/>',
'bolt':'<path d="M13 2L5 14h6l-1 8 9-13h-7z"/>',
'calendar':'<rect x="4" y="5" width="16" height="15" rx="2"/><path d="M4 10h16 M8 3v4 M16 3v4 M8 14h2 M14 14h2 M8 17h2 M14 17h2"/>',
'papers':'<path d="M7 3h11v15H7z M4 6v15h11 M10 7h5 M10 10h5 M10 13h3"/>',
'star':'<path d="M12 3l2.8 5.7 6.2.9-4.5 4.4 1.1 6.2-5.6-3-5.6 3 1.1-6.2L3 9.6l6.2-.9z"/>',
'path':'<path d="M5 20c0-9 14-2 14-11S5 9 5 3"/><circle cx="5" cy="20" r="2"/><path d="M3 3h4"/>',
'cup':'<path d="M8 4h8v5a4 4 0 0 1-8 0z M8 6H5a3 3 0 0 0 3 4 M16 6h3a3 3 0 0 1-3 4 M12 13v4 M8 20h8 M9 17h6"/>',
'variety':'<path d="M7 3l4 7H3z M14 4h6v6h-6z M4 15l4-3 4 3-2 6H6z"/><circle cx="17" cy="17" r="4"/>',
'both':'<path d="M4 14l5-9 5 9z M14 14l4-4 4 4-4 6z"/>'}
SELECTION={'first_wave':'wave','waves25':'wave','waves100':'book','win':'cup','win5':'cup','stars12':'star','stars24':'star','circle':'rings','architect':'rings','variety':'variety','builder50':'build','upgrade25':'pencil','spec1':'pencil','kills100':'eraser','kills1000':'eraser','kills5000':'eraser','boss':'crown','boss10':'crown','perfect':'shield','perfect10':'shield','wave12':'wave','wave20':'wave','research10':'flask','heal10':'heal','healall':'heal','power1':'bolt','power25':'bolt','daily1':'calendar','daily7':'calendar','both':'both','papers':'papers','daily30':'calendar','dailystars':'star','score3000':'cup','score10000':'cup','path1':'path','path4':'path','pathall':'path','pathstars12':'star','pathstars24':'star','pathperfect':'shield','pathkills':'eraser','pathbuild':'build','pathlevel':'flask','best_score':'cup','best_wave':'wave','total_stars':'star'}
def artwork(item,board,index):
    key=item['id'].split('.')[-1];shape=MOTIFS[SELECTION[key]];color=COLORS.get(item.get('group'),'#c3dccb')
    goal=item.get('goal',0);label=str(goal) if goal>1 else ''
    if goal>=1000 and goal%1000==0:label=f'{goal//1000}k'
    marks=''
    # A distinct numbered sequence of short perimeter marks identifies each badge even
    # where two goals share a pictogram (e.g. notebook stars versus path stars).
    for n in range(index+1):
        a=math.radians(-135+n*270/47);x=512+350*math.cos(a);y=512+350*math.sin(a)
        marks+=f'<circle cx="{x:.2f}" cy="{y:.2f}" r="5" fill="{INK}"/>'
    milestone=f'<text x="512" y="770" fill="{INK}" font-family="DejaVu Sans" font-weight="bold" font-size="83" text-anchor="middle">{label}</text>' if label else f'<path d="M484 742l22 22 38-45" fill="none" stroke="{INK}" stroke-width="12" stroke-linecap="round"/>'
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024"><defs><pattern id="grid" width="64" height="64" patternUnits="userSpaceOnUse"><path d="M64 0H0V64" fill="none" stroke="#dce5df" stroke-width="1.4"/></pattern></defs><rect width="1024" height="1024" fill="{PAPER}"/><rect width="1024" height="1024" fill="url(#grid)"/><circle cx="512" cy="512" r="320" fill="{color}" stroke="{INK}" stroke-width="8"/><circle cx="512" cy="512" r="306" fill="none" stroke="{INK}" stroke-opacity=".22" stroke-width="2"/>{marks}<g transform="translate(292 {292 if not board else 292}) scale(18.33)" stroke="{INK}" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round" fill="none">{shape}</g>{'' if board else milestone}</svg>'''
def main():
    defs=json.loads((ROOT/'assets/gamecenter/definitions.json').read_text());OUT.mkdir(parents=True,exist_ok=True)
    assert len(defs['achievements'])==44 and sum(a['points'] for a in defs['achievements'])==945 and len(defs['leaderboards'])==3
    encoded=''.join((ROOT/('assets/branding/'+name)).read_text().strip() for name in ['app-icon-white-paper.webp.base64','app-icon-white-paper.webp.base64.part2'])
    raw=base64.b64decode(encoded,validate=True)
    assert hashlib.sha256(raw).hexdigest()=='306b94a045708024dedfe3915339ad5ac1ec76e313a033d34421904af4ea99d0','Approved icon source changed'
    icon=Image.open(io.BytesIO(raw)).convert('RGB');assert icon.size==(1024,1024)
    icon.save(ROOT/'ios/ConfusedSketch/Assets.xcassets/AppIcon.appiconset/AppIcon.png',dpi=(72,72))
    manifest=[]
    for kind in ('achievements','leaderboards'):
        for item in defs[kind]:
            svg=artwork(item,kind=='leaderboards',len(manifest));name=item['id']
            (OUT/f'{name}.svg').write_text(svg)
            im=Image.open(io.BytesIO(cairosvg.svg2png(bytestring=svg.encode()))).convert('RGB')
            im.save(OUT/f'{name}.png',dpi=(72,72));digest=hashlib.sha256((OUT/f'{name}.png').read_bytes()).hexdigest()
            manifest.append({'id':name,'kind':kind,'file':f'{name}.png','sha256':digest,'size':[1024,1024]})
    assert len({a['sha256'] for a in manifest})==47,'Artwork must be distinct'
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    sheet=Image.new('RGB',(7*190,7*218),'#f1f4ef');draw=ImageDraw.Draw(sheet)
    for i,a in enumerate(manifest):
        x=i%7*190;y=i//7*218;im=Image.open(OUT/a['file']);assert im.mode=='RGB' and im.size==(1024,1024)
        sheet.paste(im.resize((180,180)),(x+5,y+5));draw.text((x+6,y+188),a['id'],fill=INK)
    sheet.save(OUT/'contact-sheet.jpg',quality=92)
    print('Verified: approved opaque RGB icon, 44 unique achievement images, 3 leaderboard images, 945 points, 1024x1024 at 72 dpi.')
if __name__=='__main__':main()
