# Prompts M43 · Generador integrado image_gen

Especificación normalizada de los cuatro prompts enviados. Fuentes originales sin modificar en sources/; referencia de enemigos: assets/sprites/enemies/rendered/healer.png (Curandero anterior). Referencia de Mecánico: assets/sprites/towers/rendered/turret_cannon.png. Cada recurso se generó por separado, con transparent_background=true, sin API/CLI externo.

## Condiciones comunes de los enemigos
Production transparent RGBA monster sprite sheet for dark fantasy tower defense. Reference STYLE only: polished sculptural 3D painted/rendered monster, crisp materials, elevated orthographic camera, top-left light. Exactly sixteen full-body sprites in four columns by four rows, same character and scale. Rows east/right, south/front, west/left, north/back. Columns four genuinely different consecutive walking gait poses. Complete feet, horns, staff, cape and tail; transparent gutters without overlap. Stable ground line. No text, grid, labels, drop shadows, ground or scene. Readable silhouette at34px. True transparent square background.

## Embestidor
Reference anatomy is starting point: bulky quadruped becomes recognizable RAMMING beast. Remove glowing green bulb, replace with heavy dark slate and rust bronze bony armor. Massive reinforced ivory forehead and blunt forward sweeping horns, lowered head, thick shoulders, short powerful legs. No dinosaur runner, no glow or magical staff. Walking/trotting gait. Sixteen sprites will be packed into1024×1024 atlas.

## Curandero
NEW HEALER, radically different silhouette from quadruped. Upright hunched creature, yellow-green moss skin, knotted root feet, narrow stern eyes, not cute. One large crooked wood staff capped with lime glowing medicinal seed/pod held forward to mend allies; herbal satchel on belt. Large clear staff silhouette, luminous seed only, no ground aura (game draws aura). Earthy brown staff, warm cream seed husk. Not hooded shaman, no ramming horns, no dinosaur body or huge back shell.

## Ladrón
THIEF enemy: small wiry goblin, narrow sly eyes, oversized ragged charcoal muted dusty violet hood/cape, leather belt, LARGE brown stolen coin sack tightly held in one arm, other hand reaching furtively. Few silver coins visible at tied opening. Crouching sneaking/running gait, strong hood/sack silhouette. Not cute human, no weapon, cape does not touch adjacent cell, not wizard, no magic glow. Arms/feet genuinely moving, bag consistent.

## Mecánico (una figura, sin hoja de marcha)
Production stationary mechanical support monument, SINGLE isolated object centered, true RGBA transparency. Cannon reference for polished heavy sculptural iron and warm bronze, elevated orthographic three-quarter camera, top-left light. Monumental SILVER iron war helmet above a LARGE VERTICAL bronze gear emblem. Two compact maintenance arms gripping wrench and gear hub, military engineering statue, robust symmetrical stacked design. Helmet/gear recognizable at64px, dark iron recesses, broad silver bevels, warm bronze edges. Permanent support monument, not person/robot, not cannon; no barrel, gun, humanoid face or clipart. Compact lower attachment hub only, NO pedestal/base/platform/ground (game draws base). No embedded shadow, backdrop, text, floating effects or magical blue/green glow. Full uncropped object, transparent margins, square image.
