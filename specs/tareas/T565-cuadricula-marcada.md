# T565 · Opción «Cuadrícula marcada»

- Ejecutor · Codex (Terra 6.1) · esfuerzo medio
- Depende de · nada · Compuerta · ninguna · Tamaño · Chico a mediano

## Leer

`specs/01-spec.md`: RF-741, RF-684 (grupos de Opciones), RF-727. `.claude/rules/gdscript.md`, `.claude/rules/datos.md`, `.claude/rules/tests.md`. Modelos a copiar: `_build_defeat_advice_check` en `scenes/ui/options_menu.gd:398`, la clave `defeat_advice` en `scripts/autoload/save_manager.gd` y `tests/test_defeat_advice_options.gd`.

## Objetivo

Una casilla en Opciones que marque el borde de todas las casillas del mapa, para ver bien dónde se construye.

## Alcance

**Sí:** `scenes/ui/options_menu.gd`, `scripts/autoload/save_manager.gd` (clave `map_grid`, `false` por omisión), `scenes/levels/level.gd` o un nodo hijo nuevo que dibuje las líneas, `data/ui/cuadricula.json` y su lectura, `data/i18n/es.json` y `en.json`, tests, `CHANGELOG.md`, y `ONBOARDING.md` o `README.md` si enumeran opciones.

**No:** `SAVE_VERSION`, el editor de mapas ni el dibujo del suelo.

## Pasos

1. Crear `data/ui/cuadricula.json` con color, opacidad y grosor. Elegir valores que se vean sobre los cinco terrenos.
2. Agregar la clave y su lectura, tolerante a valores inválidos, como `boss_entrance_enabled`.
3. Dibujar las líneas en un nodo propio, sobre el suelo y los adornos y debajo de torres y enemigos. Comprobar el orden real con `obstacle_layer` y `level_decor`.
4. Reaccionar a `setting_changed` para aplicar en el acto, también desde la pausa.
5. Con zoom mínimo la línea no puede desaparecer: usar un grosor que no baje de 1 px en pantalla.
6. Excluir el editor (`map_view.gd` no usa este nodo; comprobar «Probar», que sí es una partida y **sí** la muestra).
7. Tests: valor por omisión, guardado viejo sin la clave, inválido cae en apagado, aplicar en el acto, cantidad de líneas en 20 × 9 y 26 × 12.
8. Capturas con la opción prendida en los cinco terrenos, en PC y en celular simulado.

## Hecho cuando

La opción está en «Partida y ayudas», apagada por omisión. Se guarda sin subir `SAVE_VERSION` y se aplica en el acto. Se ve en 20 × 9 y 26 × 12, con cualquier zoom. Los textos existen en los dos idiomas. Hay tests y capturas.

## Verificación

Suite completa sin `SCRIPT ERROR`, incluidos los tests de localización. **No se puede probar acá:** cómo se lee en una pantalla real de teléfono.

## Frenar si

El orden de dibujo pide tocar `MapDrawings` o `level_decor` más allá de un `z_index`.
