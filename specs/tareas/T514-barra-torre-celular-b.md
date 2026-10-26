# T514 · Implementar la barra de torre del celular CEL-B

- Ejecutor · Sonnet · esfuerzo medio-alto.
- Depende de · T511 (PR #106: formato y desborde de la barra actual) y T512 (OK de Lucas a CEL-B en D-214). Conviene después de T513 por la función de frase de `TowerText`, pero no es obligatorio · Compuerta · ninguna de arte, salvo que se use un ícono nuevo para Apuntar (los de la maqueta no son arte aprobado) · Tamaño · Mediano.

> Ficha escrita el 2026-10-26 (T512). Cierra, junto con T513, la tarea T465.

## Leer

- `CLAUDE.md`, `specs/00-constitucion.md`, `.claude/rules/gdscript.md`, `.claude/rules/tests.md`.
- `specs/01-spec.md`: **RF-722** (la barra), RF-512, RF-513, RF-550, RF-617 y RF-681 con sus enmiendas del 2026-10-26.
- `specs/04-decisiones.md`: D-214 y D-195.
- `specs/tareas/informes/T510-panel-torre-critica.md` §5 (el desborde y los formatos) y §8.
- La maqueta: `art/t465-propuesta-panel/maquetas/maqueta-celular-b.png` y `art/t465-propuesta-panel/index.html` (función `celB`). Cómo se ve hoy: `art/t465-propuesta-panel/capturas-actuales/`.

## Objetivo

Que la barra de la torre elegida en el celular entre en sus 96 px, con el texto en dos renglones cortos, «Mejorar» de 320 px mostrando lo que se compra y Apuntar reducido a un ícono con el modo.

## Alcance

**Sí:** `scenes/game/mobile_hud.gd` (estado «torre elegida»), `scripts/logic/tower_text.gd` y `scripts/logic/upgrade_deltas.gd` solo para reutilizar la frase o el par antes/después, y los tests `tests/test_mobile_ui.gd` y los `test_mobile_*` que fijan el orden o las posiciones de la barra.

**No:** los estados «vacía» y «con fantasma» de la barra; el panel de la PC (T513); los dos toques de «Mejorar» (RF-681), la venta con confirmación y el bloqueo de 0,35 s; precio, daño, venta y reglas; `data/ui/mejoras.json`.

## Pasos

1. **Texto:** dos renglones cortos a 19 o 20 px: nombre con los puntos de nivel (y el estado aturdida o desgaste en ese renglón) y, debajo, el estado actual abreviado («Daño 5 · 0,6/s · Alc. 3»; sin «Daño» en una torre de apoyo). `TowerText.decimal` para todo: coma, y el alcance con su decimal (2,5, nunca 2).
2. **Orden y tamaños (de la maqueta):** texto, × (64 × 64), Apuntar (112 × 84, ícono más el modo; no se agrega si la torre no apunta), Mejorar (320 × 84), separación de seguridad (296 px en la maqueta), Vender (150 × 84).
3. **«Mejorar» de dos partes:** arriba «Mejorar → N2» con el costo y la moneda; abajo el cambio que se compra (hasta 2 estadísticas, «alcance 2,5 → 3») en el verde del «después». Armado: «Tocá para confirmar», con costo y cambios. Sin oro: «Faltan N de oro» y los cambios. Nivel máximo: «Nivel máximo». Retirar el renglón «Al mejorar:».
4. **Separación de seguridad:** **medir** la distancia entre el borde derecho de «Mejorar» y el izquierdo de «Vender» en px lógicos y en mm del teléfono de referencia de T262. La maqueta deja ≈ 312 px y la cuenta de 35 mm da ≈ 376 px (RF-722, «límite abierto»). Si no alcanza lo que fija RF-513, correr el texto o achicar el ícono de Apuntar; **no** achicar ningún botón por debajo de 56 px (RF-550) ni «Mejorar» por debajo de 84 px de alto.
5. **Tests:** posiciones y orden de los hijos de la barra; ninguno fuera de 96 px de alto ni de la pantalla (Hielo 1 y Eléctrica 1, los casos que hoy se cortan); la separación mínima entre «Mejorar» y «Vender»; todo botón ≥ 56 px; los textos de «Mejorar» desarmado, armado y sin oro; coma decimal y «Alc. 2,5»; Estandarte sin Apuntar ni «Daño».
6. **Capturas** del celular **simulado** (`ui_mode` celular) a 1280 × 720: Hielo 1, Eléctrica 1 con «Mejorar» armado, Estandarte 1 y Ametralladora 1 sin oro. Compararlas con `maqueta-celular-b.png`.

## Hecho cuando

(Copiado de `specs/03-tareas.md`.) La barra de la torre elegida entra en 96 px de alto y ningún hijo pasa del borde de la pantalla; el texto son dos renglones cortos con coma decimal y alcance con decimales; «Mejorar» mide 320 × 84 y trae abajo el cambio que se compra (hasta 2 estadísticas), con los estados desarmado, armado («Tocá para confirmar»), sin oro («Faltan N de oro») y nivel máximo; «Apuntar» es un ícono con el modo y no aparece si la torre no apunta; no queda el renglón «Al mejorar:»; la separación entre «Mejorar» y «Vender» cumple RF-513 (medida en un test); todo botón ≥ 56 px; los dos toques y el bloqueo de 0,35 s siguen iguales; tests de posición y de separación de seguridad; GUT completo sin `SCRIPT ERROR`; capturas del celular **simulado**. No se afirma nada sobre teléfono real.

## Verificación

`godot --headless --import` y GUT completo (`… 2>&1 | grep -c "SCRIPT ERROR\|Parse Error"` da 0); `git status` después de `--import`. **No se puede probar acá:** un teléfono real (tamaño físico, letra en sp, el pulgar sobre la barra), ni Windows. Anotar el «Resultado» honesto en `specs/03-tareas.md` y, si T513 también está en `main`, cerrar T465.

## Frenar si

Con la separación de seguridad de RF-513 no entran los botones en 1264 px sin bajar de los mínimos de RF-550: consultar a Lucas (por ejemplo, pasar a CEL-A o a una barra de dos pisos). T511 todavía no está en `main`: no empezar sin él.

## Resultado

**Resultado (2026-10-26, Sonnet 5.5):** hecho, con una decisión que queda para Lucas. **Qué se hizo:** `scenes/game/mobile_hud.gd` arma la barra CEL-B: texto de dos renglones sin partir («Hielo ●○○» y «Daño 2 · 1/s · Alc. 2,5», `TowerText.bar_state` nuevo, con `TowerText.decimal`), × de 64 × 64, «Apuntar» de 112 × 84 con una mira y el modo debajo (se oculta en el Estandarte y la Disruptora), «Mejorar» de 320 × 84 de dos partes (título «Mejorar → N2  120» con la moneda `stat_gold.svg`, o «Tocá para confirmar  120» armado, o «Faltan N de oro», o «Nivel máximo»; abajo, en el verde del «después», hasta 2 estadísticas de `UpgradeDeltas.preview` con la tabla de `mejoras.json`), separación de seguridad y «Vender» de 150 × 84 con lo que devuelve («+91»). Se retiró el renglón «Al mejorar:». Los dos toques, el bloqueo de 0,35 s y la venta con confirmación no se tocaron. Los números nuevos (112, 320, 84, fuentes 20/16/15, alto de la parte de abajo) están en `data/ui/mobile_ui.json` y `mobile_ui_config.gd`. **Medido en el motor (celular simulado 1280 × 720):** la barra mide 96 px y ningún hijo pasa de ella ni de la pantalla; «Mejorar» → «Vender» = **390,0 px** de borde a borde (espaciador 373,3 px = 35 mm con 6 mm = 64 px, más 2 × 8 de la fila); la maqueta deja 312 px (≈ 29 mm), o sea que **no alcanzaba** los 35 mm de RF-512. **Qué pasó con el punto crítico:** se conservaron los 35 mm y se cedió espacio de texto, como permitía el paso 4: la columna de texto queda de 204 px (282 en la maqueta; 324 sin «Apuntar») y la letra baja de 20 px a entre 16 y 20 px (33 casos, 11 torres × 3 niveles: Hielo y Estandarte a 20, Eléctrica 1 a 17, Cañón 3 a 18); el estado aturdida o desgaste, si no entra junto al nombre, pasa a un renglón propio (tres renglones, siempre dentro de los 92 px). **Falta que decida Lucas:** si le sirve la letra de 16 a 20 px con los 35 mm, o si prefiere los ≈ 29 mm de la maqueta con la letra de 19 a 20 px (no se hizo: achicaría la separación de seguridad que pidió RF-512). Los botones no bajan de 56 px y «Mejorar» no baja de 84 de alto. **Tests:** `tests/test_mobile_tower_bar.gd` reescrito (12 tests: orden y tamaños, dos renglones, mira, «Mejorar» desarmado/armado/sin oro/máximo, Estandarte y Disruptora sin Apuntar, separación contra 35 mm, estado aturdida y desgaste, y las 11 torres en sus 3 niveles); ajustados `test_mobile_ui.gd`, `test_range_preview.gd` y `test_upgrade_preview.gd`. Sin el cambio, el test nuevo ni compila y los otros tres fallan (2, 1 y 1 tests). GUT completo: 2505/2505, 0 `SCRIPT ERROR`; `--import` salió con 0 las dos veces (no apareció el 139). Capturas reales de Godot (ventana de 1280 × 720, `ui_mode` celular simulado, herramienta `art/t465-propuesta-panel/fuentes/capture_t514_bar.gd`) en `Capturas/T514-antes-*.png` y `Capturas/T514-despues-*.png`: Eléctrica 1 (y armada), Hielo 1 y 3, Cañón 3, Estandarte, Disruptora y Ametralladora 1 sin oro. **No se probó:** un teléfono real (tamaño físico, letra en sp, el pulgar, los 35 mm reales: la cuenta de 372–376 px sale de la fórmula, no de una medición), Windows, ni el rendimiento. **Provisorio:** la mira de «Apuntar» es un SVG simple dentro del código (`AIM_SVG`), no un asset aprobado: pasa por la compuerta de arte antes de ser definitivo. La moneda es `stat_gold.svg`, ya aprobado.
