# T465 · Panel de torre sin repeticiones (propuesta A)

- Ejecutor · Sonnet · esfuerzo medio.
- Depende de · OK de Lucas a T458 (registrado) · Compuerta · ninguna de arte · Tamaño · Mediano.

> Ficha escrita el 2026-10-25 en el cierre honesto de M75 (`specs/tareas/informes/M75-cierre-honesto.md`), **después** de que el código se integrara en `main` (PR #68). Refleja lo hecho y lo que falta.

## Leer

- `CLAUDE.md`, `specs/00-constitucion.md`, `.claude/rules/gdscript.md`, `.claude/rules/tests.md`.
- `specs/01-spec.md` § M75: RF-677 (y las enmiendas de RF-616, RF-617 y RF-650).
- `specs/04-decisiones.md`: D-193.
- `specs/tareas/T458-ficha-camara-panel-opciones.md` §3.

## Objetivo

Que el panel de torre de la PC muestre cada dato una vez: «antes → después» en su lugar, sin «Al nivel N:» ni «Nivel N/3», decimales con coma y la tarjeta de nivel en bronce, plata y oro.

## Alcance

**Sí:** `scenes/ui/tower_panel.gd` y `.tscn`, `scripts/logic/tower_text.gd`, `scripts/logic/upgrade_deltas.gd`, `scenes/game/mobile_hud.gd` (solo el formato compartido).

**No:** precio, daño, venta ni reglas de mejora; números nuevos fuera de `data/ui/mejoras.json`.

## Estado al 2026-10-25 (verificado contra `main` e121f0c)

Hecho y comprobado:
- Sin «Al nivel N:» ni «Nivel N/3»; tooltip «Nivel actual: N de 3»; tarjeta bronce/plata/oro (`#d7a45b`, `#94a8b9`, `#f0d176`): `tests/test_upgrade_preview.gd` y `tests/test_tower_panel_layout.gd`.
- Daño, cadencia, alcance y efectos con «antes → después» una sola vez, niveles 1 y 2 de Cañón, Tesla, Hielo, Fuego y Disruptora: `test_panel_shows_each_upgrade_value_once_for_cannon_tesla_ice_and_disruptor`.
- Mismo cálculo que la barra del celular: `UpgradeDeltas.preview` en `tower_panel.gd:118` y `mobile_hud.gd:297`.
- Disruptora sin cadencia/radio/daño repetidos (`TowerText.panel_pulse_line`).
- Ancho: el test usa «0,75 → 0,85/s» con la fuente del juego. En la ventana real, con los 12 casos (4 torres × 3 niveles) a 1920 × 1080, el panel mide 270 px y ningún texto sin ajuste de línea se pasa de su columna (renglón más ancho sin ajuste: 242 px).
- Capturas: `Capturas/M75-T465-panel-12-casos-1920x1080.png`, `…-1280x720.png` y `Capturas/M75-T465-panel-tesla-n1-1920x1080.png`.
- Arreglado en el cierre: el Cañón de nivel 3 mostraba «Área: radio 1.5» (con punto) porque `TowerText.effects` usaba `%.1f`. Ahora usa `TowerText.decimal`. Test nuevo: `test_panel_at_level_three_has_no_arrows_and_no_decimal_point` (nivel 3 de las cuatro torres: sin punto, sin flechas, «Nivel máximo»). Falla sin el arreglo.

Falta (decisión de Lucas):
1. **RF-677 punto 1 no se cumple al pie de la letra.** El RF dice que se elimina el bloque aparte (`UpgradePreview`) y que lo que cambia en los efectos se ve **en su lugar**. El código conserva el nodo `UpgradePreview` (`tower_panel.gd:106-140`), sin rótulo, **entre «Apuntar» y «Mejorar»**, y saca de la lista de efectos el renglón que cambia. Por eso «área 1 → 1,2», «saltos 2 → 3» o «s de pulso 2,5 → 3» quedan lejos de su efecto y con un rótulo corto de `data/ui/mejoras.json`. Hay dos salidas: aceptar el bloque y enmendar RF-677 (tarea 📜) o mover esos renglones a la lista de efectos (código).
2. Observaciones visuales para la misma revisión: el Hielo llena la lista de efectos y necesita barra de desplazamiento (en el nivel 3, «Voladores: sí» queda debajo del corte); el Hielo de nivel 2 parte «… s de frenado 2 → 3» en dos renglones; rótulos cortos poco claros («s de frenado», «s de pulso»).

## Hecho cuando

(Copiado de `specs/03-tareas.md`.) Sin «Al nivel N:» ni «Nivel N/3»; daño, cadencia, alcance y efectos con «antes → después» una vez; ningún decimal con punto; la Disruptora no repite; tarjeta bronce/plata/oro con tooltip; el texto más largo (Tesla de nivel 1) entra en 270 px (test de ancho); mismo cálculo que el celular; tests actualizados y casos nuevos para Cañón, Tesla, Hielo y Disruptora en niveles 1 a 3; capturas a 1280 × 720 y 1920 × 1080. No cambia precio, daño, venta ni reglas.

## Verificación

GUT completo sin `SCRIPT ERROR`. Capturas y medición: `DISPLAY=:0 godot --path . -s res://tools/capture_m75_cierre.gd -- /ruta/fuera/del/repo fullscreen` (y `1280x720`); las líneas `T465 ancho · …` tienen que decir `OK`. **No se puede probar acá:** Windows.

## Frenar si

Mover los renglones de efectos obliga a agrandar el panel (270 px) o a cambiar `data/ui/mejoras.json`: consultar a Lucas.
