# T372 · 🎨 «Novedades de esta versión»: cabecera, íconos y variante sobria (M67)

> **Estado: PENDIENTE, a la espera del OK de Lucas a la spec M67 (`01-spec.md`, RF-603 a RF-609) y a las preguntas P-67-1 (qué dice la 1.0.0) y P-67-6 (con o sin imágenes).** Las decisiones son **D-141 a D-144**. Esta ficha es el **encargo de arte**; el código lo hace T373 (sin imágenes, con `_draw`) y T375 integra lo que Lucas apruebe. **Los íconos dependen de los ítems finales**: si Lucas cambia la lista del borrador, se ajusta el encargo antes de producir.

- **Ejecutor:** **Codex `gpt-6.1-sol`, esfuerzo medio** · **Depende de:** T370 · **Compuerta:** 🎨 **Lucas aprueba las muestras antes de integrar** (nada va a `assets/` hasta entonces) · **Tamaño:** mediano

## Leer
`specs/tareas/README.md` §6, `.claude/rules/arte.md`, **`specs/05-guia-de-arte.md` entera** (sobre todo §2, §5, §7 «Familia A: hierro oscuro, bronce y madera» y M37 «Apoyo y avance coleccionable»), y de `01-spec.md` solo **M67** (RF-604, RF-605 y el borrador de la 1.0.0). Mirar `assets/ui/menu_theme.tres` (colores y paneles del menú), `assets/sprites/ui/` o donde estén los íconos de T221, el logo del menú principal (`tools/prepare_logo.gd`) y las láminas de la intro (`assets/intro/`, estilo «Cuaderno de bitácora») para que la cabecera **se vea de la misma familia**. Canon del universo: `specs/10-universo.md` (colonia, Moradores, tono).

## Qué hay que producir
Tres cosas, todas **sin texto** (el texto lo pone el juego) y **sin el símbolo A** ni emblemas de comunidades:

1. **Cabecera de la presentación** (`news_header_1_0.png`): una ilustración **apaisada** para la parte de arriba de la pantalla de la **1.0.0**. Una vista **amplia y optimista** del campamento en el oasis: **varias torres de distintos estilos en línea de defensa**, el camino al fondo y, a lo lejos, la silueta de **uno o dos monstruos grandes** (el Jefe carmesí y el Coloso de basalto) sin amenaza inmediata. Mismo mundo que las láminas de la intro, pero **más luminoso** (es la salida del juego, no el comienzo). **Sin personas en primer plano**. **El centro y la parte baja tienen que quedar tranquilos** (ahí cae el título y el subtítulo que dibuja el juego; zona libre de detalles importantes: el **40 % de abajo**).
2. **Cabecera sobria de «Mejoras»** (`news_header_plain.png`): una **banda** de hierro y bronce con remaches y un grabado abstracto (engranajes, tornillos, líneas de plano), **sin escena**, que sirve para **todas** las versiones siguientes sin rehacerla. Que no compita con el texto.
3. **Íconos de las novedades** (`news_icon_<nombre>.png`): **8 íconos** para el borrador de la 1.0.0 (se ajusta a la lista final de Lucas):

| Archivo | Para | Qué se dibuja (sugerencia) |
|---|---|---|
| `news_icon_map.png` | 15 niveles, una historia | pergamino/mapa doblado con un camino y una cruz |
| `news_icon_tower.png` | Torres que se mejoran | una torre/cañón con tres muescas de nivel |
| `news_icon_monster.png` | Monstruos con carácter | la silueta de una bestia con cuernos (como el Jefe) |
| `news_icon_siege.png` | Asedio | una muralla con una flecha/ariete que la golpea |
| `news_icon_editor.png` | Tus propios mapas | una cuadrícula con una casilla y una herramienta (pala o escuadra) |
| `news_icon_mobile.png` | PC y celular | un celular chico delante de un monitor |
| `news_icon_book.png` | Intro y tutorial | un cuaderno de bitácora abierto |
| `news_icon_upgrade.png` | Mejoras y jefes con entrada (opcional) | una flecha hacia arriba sobre una chispa |

**Los íconos son una familia**: el mismo **medallón** (un disco de hierro con borde de bronce y remaches chicos) con el dibujo adentro, **mismo contorno `#2b2233` de ancho 2** (guía §2: piezas de hierro y bronce), **degradé de 3 paradas** (luz, medio, sombra) y **una sola línea de brillo** por pieza grande. Fondo transparente. **Nada de letras ni números.**

## Formato (cerrado, para que T375 sea solo reemplazar archivos)
- **Cabecera de la presentación:** PNG **1280 × 320** (4:1), **opaco**, `assets/ui/novedades/news_header_1_0.png`. Se muestra a **100 %** en el panel de 880 px (celular) o 720 px (PC): el juego la **escala al ancho del panel** manteniendo la proporción, así que **la composición tiene que aguantar 720 px de ancho** (el detalle importante, en el centro-izquierda; nada vital a menos de 80 px de los bordes).
- **Cabecera sobria:** PNG **1280 × 160** (8:1), opaco, `news_header_plain.png`; los **bordes izquierdo y derecho se pueden repetir** (patrón sin costura en el centro), por si el panel es más ancho.
- **Íconos:** PNG RGBA **96 × 96**, un archivo por ícono. Se muestran a **64 px** en el celular y a **48 px** en PC: **tienen que leerse a 48 px** (un detalle que desaparece a 48 px se saca o se agranda, guía §1).
- **Peso:** cabecera de la presentación **menos de 350 KB** (**importada sin mipmaps no más de 1 MiB**, medida como en `art/intro-v1/peso.py`), sobria **menos de 100 KB**, cada ícono **menos de 20 KB**. Anotar el peso real. (La APK ya fue ajustada en M62: no se puede engordar a lo loco.)
- **Fuentes sin perder el original** en `art/novedades-m67/sources/`; empaquetador si hace falta (`pack.gd`) en `art/novedades-m67/`; **prompts normalizados** en `prompts.md`; `manifest.json` (nombres, tamaños, uso).

## Cómo se ve a escala real (obligatorio antes de mostrárselo a Lucas)
1. **Maqueta de la pantalla** (`art/novedades-m67/mockup_pc.png` y `mockup_mobile.png`): una pantalla de **1280 × 720** con el panel de hierro y bronce, la cabecera, el título «Monsters & Canons 1.0» y el subtítulo del borrador, las **8 filas** con ícono de 48 px (PC) o 64 px (celular) y los textos del borrador de la spec, y el botón «Entendido» abajo. Y la misma a **2400 × 1080** (celular real, 1,875×) para ver el tamaño de los íconos y la nitidez. Los **textos de ejemplo tipográficos van solo en la maqueta**, no en los PNG.
2. **Hoja de contacto de los íconos** a **100 %** (96 px), **64 px** y **48 px**, sobre el fondo oscuro del menú, para revisar la silueta de cada uno y que **no se confundan entre sí** a 48 px.
3. **Cabecera sobre el fondo del menú** a 720 y 880 px de ancho, con la zona de texto superpuesta (rectángulos de ejemplo) para comprobar que **el título se lee** sobre la parte baja.
4. **Contraste del texto:** que el título (crema `#f4ecd8`) y el subtítulo se lean sobre la cabecera, con la relación de contraste anotada.
5. **Un HTML de comparación** en `art/novedades-m67/comparison.html` (como `art/intro-v1/comparison.html`) con todo lo anterior.

## Pasos
1. Producir primero **una muestra**: la cabecera de la presentación, la sobria y **dos íconos** (el mapa y la torre), más la maqueta. **No tocar** `assets/`.
2. **Mostrarle la muestra a Lucas** (🎨). Con su OK al estilo, hacer los íconos que faltan y la hoja completa; con su OK a la hoja, seguir.
3. Con el OK **por escrito** (anotado en la entrada de T372 de `03-tareas.md`), copiar los archivos finales a `assets/ui/novedades/`. **No** editar código: T375 los conecta. Si el código necesita otra cosa, **anotarlo**.

## Hecho cuando
La cabecera de la presentación, la sobria, los 8 íconos (o los de la lista final), la maqueta en PC y celular, las fuentes, `prompts.md`, `manifest.json`, la hoja de contacto y el HTML de comparación están en `art/novedades-m67/`; Lucas dio su OK por escrito; los PNG finales están en `assets/ui/novedades/` con el peso anotado. Commit `T372: …`.

## Frenar si
- Lucas no contestó P-67-1 (la lista de ítems cambia los íconos) o P-67-6 (si no quiere imágenes, **no se produce**).
- Una ilustración muestra a los **Moradores**, animales, ruinas, el **símbolo A** o el nombre del planeta, que el canon reserva para otros momentos (`10-universo.md`, y la lista de «lo que no aparece» de T241): **preguntar**.
- Un ícono necesita más de 3 colores para leerse a 48 px: **simplificar el dibujo**, no agregar color.
- La cabecera no entra en el peso sin perder calidad visible: **avisar el peso** y proponer 1280 × 240 antes de recortar a ciegas.
- El estilo de la cabecera no se parece a las láminas de la intro ni al menú: **mostrarle a Lucas la comparación lado a lado** antes de seguir.
