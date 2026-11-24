# T597 · Preparar la subida a Google Play

- **Refs:** RF-756, RF-757, D-237 · **Depende de:** nada para preparar; la versión final del juego (`config/version`, Novedades) sigue en T268/T375 · **Ejecutor:** Claude (Opus) prepara; **Lucas** crea la clave de subida, completa la consola y sube.

## Qué hay que hacer

1. Preset **«Android Play»** en `export_presets.cfg`: AAB con Gradle, mismo paquete, versión, arquitectura y filtros que «Android». Paquete `com.monsterscanonsv1.game` en los dos (elegido por Lucas). `version/code = 4`; `version/name` sigue vacío (sale de `config/version`, que pasa a `1.0.0` en T268/T375).
2. Comprobar que el AAB se arma en la PC de Lucas (con la clave de depuración; la de subida es de Lucas).
3. `PRIVACY.md` en la raíz y `specs/publicacion/play-store.md` con textos, formularios, pasos de la consola, clave de subida y actualizaciones.
4. Gráficos en `art/play-store/` con `tools/play_store_graphics.gd`. Las capturas las saca Lucas en el teléfono (o se generan aparte).
5. ONBOARDING §7.3 y §7.5, CHANGELOG, notas de la 1.0 y CLAUDE.md al día.

## Hecho cuando

El preset exporta un AAB, la ficha, la privacidad y los gráficos están listos, y Lucas tiene los pasos para la consola. **No** incluye subir nada a Play: eso es de Lucas (T239).
