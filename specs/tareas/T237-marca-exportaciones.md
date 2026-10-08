# T237 · Marca y exportaciones de Windows, Linux y Android

- **Ejecutor:** Sonnet 5.5 · esfuerzo **bajo**
- **Depende de:** T236 y Q-04 · **Compuerta:** si Q-04 dijo "no", se hace solo la parte 2 · **Tamaño:** chico

## Leer
D-077, RF-383 a RF-387, `export_presets.cfg`, `project.godot` (nombre de la aplicación y de la ventana), `ONBOARDING.md` (cómo se exporta) y el Resultado de T196 y de T179 (Android).

## Pasos
1. **Marca (si Q-04 dijo sí):**
   - nombre de la aplicación y de la ventana: "Monsters & Canons";
   - archivos: `MonstersCanons.exe`, `MonstersCanons.x86_64` y `MonstersCanons.apk`;
   - el paquete Android que decidió Lucas;
   - la versión `1.0.0` (code de Android, el siguiente al actual).
   Actualizar **todos** los lugares donde aparece "JuegoA": `grep -rn "JuegoA" --include=*.md --include=*.cfg --include=*.godot .`. La **carpeta del proyecto y el repositorio no se renombran**.
2. **Exportar** las tres plataformas en `build/`. En Linux: `godot --headless --path . --export-release "<preset>" build/<archivo>`. Borrar de `build/` los ejecutables viejos que quedaron obsoletos (T196 ya lo anotó).
3. **Verificar:**
   - el ejecutable de Linux arranca en esta máquina y llega al menú (salida 0 en `--headless` con un `--quit-after`, o una captura con ventana);
   - la APK con `apksigner verify` y `aapt dump badging` (paquete, versión y nombre);
   - el de Windows: que existe y que su tamaño es razonable (no hay Windows en esta máquina: anotarlo).
4. El artículo de licencias de la Wiki sigue estando, y `LICENSE` va junto a los ejecutables si el preset lo permite.

## Hecho cuando
Las tres builds están en `build/`, la de Linux probada y la APK verificada, y los documentos actualizados. Resultado, `CHANGELOG.md` ("Versión 1.0"), commit y PR.
