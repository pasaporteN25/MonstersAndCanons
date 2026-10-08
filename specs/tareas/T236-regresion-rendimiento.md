# T236 · Regresión, guardados viejos, rendimiento y auditoría de recursos

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T234 (y T235) · **Compuerta:** ninguna · **Tamaño:** mediano

## Leer
- `specs/00-constitucion.md` (P7: rendimiento).
- 07 §12 (criterio de entrega completa).
- `tools/perf_test.gd` y `art/mechanics-m41/performance.gd`.
- La sugerencia "Auditoría de recursos" de §13, que esta tarea **aprueba y hace**.
- `scripts/autoload/save_manager.gd`.

## Pasos
1. **Tests completos** con cero `SCRIPT ERROR`. Anotar el número de tests (más de 1017).
2. **Campaña con el bot:** `mix levels=1-15 seeds=5` y `check_rule=1` (T214). Todo tiene que pasar. La tabla va al Resultado.
3. **Guardados viejos:** con guardados de prueba que imiten:
   - un guardado de antes de M50, con `technology` y los niveles 1 a 9;
   - uno con la colección completa;
   - uno del modo de pruebas.
   Verificar que cargan, que conservan el progreso y que el 10 se desbloquea si el 9 estaba ganado. Agregar tests si faltan.
4. **Rendimiento P7:** la carga de 200 enemigos y 60 torres, con demolición, extracción y pulsos de la Disruptora activos. Comparar con la medición de M43 (114 FPS promedio en este equipo). Anotar la máquina.
5. **Auditoría de recursos:** un test nuevo que recorra **todos** los `.tres`, los niveles, `progression.json` y la Wiki, y verifique que toda ruta a una imagen o sonido existe y que no hay ids de colección, torre o enemigo sueltos.
6. Una lista de lo que **no** se probó: celular real y Linux real, salvo que Lucas lo haga en T238.

## Hecho cuando
Todo lo de arriba, con su Resultado honesto. Commit y PR.

## Frenar si
- El bot no gana algún nivel con `sin_recursos`: es un problema de balance y vuelve a la tarea de ese nivel.
- El rendimiento cae más de un 25 % contra M43.
