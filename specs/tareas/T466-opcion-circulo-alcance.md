# T466 · Opción «Círculo de alcance», fantasma y arco del Estandarte

- Ejecutor · Sonnet · esfuerzo medio.
- Depende de · OK de Lucas a T458 (registrado) · Compuerta · ninguna de arte · Tamaño · Mediano.

> Ficha escrita el 2026-10-25 en el cierre honesto de M75 (`specs/tareas/informes/M75-cierre-honesto.md`), **después** de que el código se integrara en `main` (PR #69). Refleja lo hecho.

## Leer

- `CLAUDE.md`, `specs/00-constitucion.md`, `.claude/rules/gdscript.md`, `.claude/rules/tests.md`, `.claude/rules/datos.md`.
- `specs/01-spec.md` § M75: RF-678, RF-679, RF-683, RF-685.
- `specs/04-decisiones.md`: D-194 y D-196.
- `specs/tareas/T458-ficha-camara-panel-opciones.md` §4.

## Objetivo

Una opción «Círculo de alcance» (Oculto por omisión, Sutil, Completo) que decide cómo se ve el alcance de la torre construida y elegida y el arco del Estandarte mecánico. El fantasma de construcción muestra siempre el círculo completo.

## Alcance

**Sí:** `scripts/autoload/save_manager.gd` (`range_display`), `scenes/ui/options_menu.gd`, `scenes/game/build_controller.gd`, `scenes/towers/tower.gd`, `data/ui/alcance.json` y su lector/validador (`RangeDisplayConfig`, `tools/check_alcance.gd`).

**No:** la ampliación al mejorar (es T467), `SAVE_VERSION`.

## Estado al 2026-10-25 (verificado contra `main` e121f0c)

Todo comprobado:
- `settings.range_display` con lectura defensiva y sin subir `SAVE_VERSION`: `tests/test_range_display.gd` (`test_range_option_defaults_to_hidden_including_an_old_save`, `test_invalid_saved_values_warn_and_fall_back_to_hidden`, `test_invalid_setter_values_fall_back_to_hidden`) y `tests/test_old_saves.gd`.
- Fila en Opciones en PC y celular: `test_range_option_sits_with_upgrade_animation_option`, `test_mobile_options_keep_the_range_row_touchable_and_inside_the_panel`, `test_options_groups.gd`.
- Fantasma siempre completo y torre construida según la opción: `test_ghost_is_always_complete_and_placed_tower_uses_the_setting` (lógica pura) y su uso en `build_controller.gd:533` y `:562`. «Al instante»: `build_controller.gd:593` y `tower.gd:520` redibujan con `setting_changed`; en la ventana real, la herramienta cambia la opción con la torre ya elegida y la captura 3 cuadros después ya muestra el estilo nuevo.
- Arco del Estandarte según la opción y nada si está aturdido: `test_stunned_support_tower_is_not_drawn_as_active` y su uso en `tower.gd:439`.
- Valores de dibujo en `data/ui/alcance.json`: `test_range_drawing_data_matches_the_approved_styles`, `test_full_range_color_comes_from_the_data`.
- Capturas de Sutil y Completo sobre los 15 fondos, recortadas **a tamaño real** alrededor de una Ametralladora elegida (1920 × 1080): `Capturas/M75-T466-alcance-sutil-15-niveles-recorte-1920x1080.png` y `Capturas/M75-T466-alcance-completo-15-niveles-recorte.png` (esta, a la mitad). Las capturas viejas `Capturas/T466-*-15-niveles.png` son de antes de T465 (el panel todavía dice «Al nivel 2:») y están achicadas: no alcanzan para juzgar el borde de 1 px.

**Qué fondos no se leen bien (lo que pide el criterio):** el **Completo** se lee en los 15. El **Sutil** (borde blanco de 1 px con opacidad 0,3) se ve en pasto y piedra (niveles 1 a 9, 14 y 15), apenas se ve en la arena del desierto (niveles 10 a 12) y **casi no se ve sobre la nieve (nivel 13)**. Si Lucas quiere corregirlo es un cambio de datos (`data/ui/alcance.json`: más opacidad o un color que no sea blanco), sin código.

## Hecho cuando

(Copiado de `specs/03-tareas.md`.) `settings.range_display` con defensa y sin subir `SAVE_VERSION`; la fila en Opciones (PC y celular); el fantasma siempre completo; la torre construida solo con Sutil o Completo, al instante; el arco de apoyo sigue la opción y aturdida no lo dibuja; valores en `data/ui/`; `test_range_display.gd` nuevo; capturas de Sutil y Completo sobre los 15 fondos (se informa si alguno no se lee).

## Verificación

GUT completo sin `SCRIPT ERROR`. Capturas: `DISPLAY=:0 godot --path . -s res://tools/capture_m75_cierre.gd -- /ruta/fuera/del/repo fullscreen` (hojas `T466-alcance-*-15-niveles-recorte-*.png`). **No se puede probar acá:** un teléfono real ni Windows.

## Frenar si

Hace falta cambiar el color del Sutil por uno que no esté en la guía de arte: mostrar la propuesta a Lucas.
