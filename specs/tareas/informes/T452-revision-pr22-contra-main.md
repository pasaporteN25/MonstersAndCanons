# T452 · Revisión del PR #22 (M71) contra `main` — no integrar

**Fecha:** 2026-10-23 · **Rama de trabajo:** `feature/t452-revision-pr22` (salió de `origin/feature/arte-integracion-m65-m67` y se le mezcló `origin/main` = `250e724`).
**Alcance:** solo análisis. No se tocó el PR #22 ni su rama, no se hizo cherry-pick y no se cambió código del juego. El PR #22 **no se mezcla, no se da por listo y no se cierra**: todo lo de abajo es una propuesta para que decida Lucas.

## 1. Qué se hizo y qué dio

1. `git merge origin/main` sobre la rama del PR: **sin conflictos** (ni de texto ni de fondo). Commit de merge `aa812f1`. El PR queda 41 commits adelante de su base y ya contiene a `main` (T417 ya había sincronizado una vez; este merge trae lo que entró después, hasta el PR #46).
2. `godot --headless --import`: terminó sin errores (solo el aviso ajeno `cannot connect to daemon at tcp:5037`, del adb). `git status` quedó limpio: el import no reescribió ningún archivo versionado.
3. GUT completo (`godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`), versión Godot `4.7.2.stable.official.ed1daf0bf`:
   - **Scripts 159 · Tests 2230 · Passing 2230 · Asserts 24195 · Time 116,005 s.** «All tests passed!». Deprecated 1 (lo trae GUT).
   - **`SCRIPT ERROR`: 0** (contado con `grep` sobre la salida completa). Hay un solo `ERROR:` («El nivel no_existe tiene errores y no se va a jugar»), que es el de la prueba esperada del nivel inválido, y varios `WARNING` de pruebas que fabrican archivos rotos a propósito.
   - Contexto de la máquina para esa corrida: AMD Ryzen 5 3600 (12 hilos), GTX 1660 SUPER, `load average` al arrancar **18,05 / 7,85 / 3,74** (máquina cargada por otros agentes; 3,06 unos minutos después). Fue una corrida de tests, no de rendimiento: el tiempo de 116 s no sirve como medición.
4. **No se corrió `perf_test`.** Por lo tanto este informe **no afirma ninguna medición de rendimiento**. Lo que dice el PR sobre RF-629/RF-643 son números de T414 hechos por otro agente con la máquina saturada (el propio `03-tareas.md` deja T364/T369 abiertas); acá no se verificaron.
5. **No se probó** nada en un celular real, ni se miró el arte dentro del juego (capturas): la revisión del arte se hace por los archivos y los tests.

## 2. Estado del PR respecto de `main`

Diferencia real (`origin/main...origin/feature/arte-integracion-m65-m67`): 143 archivos, de los cuales ~100 son `art/t362-muestras/` y `art/t367-muestras/`. En código y datos solo cambian: `scenes/effects/{upgrade_effect,boss_entrance_burst,effects_layer}.gd`, `scenes/ui/boss_entrance_card.gd`, `scripts/data/boss_entrance_config.gd`, `data/ui/entrada_jefes.json`, `tools/perf_test.gd`, `tests/test_upgrade_fx.gd`, `tests/test_boss_entrance_hud.gd`, `tests/test_save_backup.gd.uid`, los cinco PNG con su `.import`, y los documentos. Ninguno de esos archivos de código cambió en `main` desde la base: por eso el merge es limpio.

Números ya tomados por el PR (no se reusan): **RF-625 a RF-629, RF-643, D-165, D-176, T410 a T417**.

## 3. Tabla commit × archivo → decisión propuesta

Leyenda: **CONSERVAR** (se rescata tal cual o con el recorte indicado) · **REHACER** (integra el concepto viejo de jefe de T367: hay que volver a pedirlo/escribirlo cuando Lucas apruebe la nueva M66) · **RETIRAR** (no debe entrar a `main`).

| Commit | Archivo / parte | Decisión | Motivo |
|---|---|---|---|
| `d40cdb3` T410 | `art/t362-muestras/**` (muestras de mejora, incl. `upgrade_l2/l3.png`, fuentes y `validate.py`) | CONSERVAR | Es el arte de T362 que Lucas aprobó; es la procedencia de los atlas. |
| `d40cdb3` T410 | `art/t367-muestras/**` (destello, grieta, marco, `review/`) | REHACER | Es el concepto viejo del jefe (cartel de 720×120 que no pausa, D-138); la nueva M66 pide presentación a pantalla completa. Conviene no mezclarlo hasta que Lucas decida. |
| `d40cdb3` T410 | `01-spec.md` M71: RF-625, RF-628 (parte de mejoras), RF-629 (pruebas `mejoras`/`sin_fx`/`celular`) | CONSERVAR | Describen solo `UpgradeEffect`. |
| `d40cdb3` T410 | `01-spec.md` M71: RF-626, RF-627, parte de jefe de RF-628/RF-629 (`entrada_jefe`) | REHACER | Destello, grieta y marco del cartel viejo. |
| `d40cdb3` T410 | `04-decisiones.md` D-165, `02-plan-tecnico.md` puntos 2 y 4 (T412/T413), `03-tareas.md` T410 a T415 | CONSERVAR la parte de mejoras; REHACER la de jefe | D-165 mezcla las dos cosas: hay que partirla (ver §5). |
| `c535b30` T411 | `assets/sprites/effects/mejora/upgrade_l2.png`, `upgrade_l3.png` y sus `.import` | CONSERVAR | Atlas aprobado de T362. |
| `c535b30` T411 | `scenes/effects/upgrade_effect.gd`, `scenes/effects/effects_layer.gd` (parámetro `footprint`), `tests/test_upgrade_fx.gd` | CONSERVAR | Sprite2D + `Tween`, sin `_process`; los tests de mejora pasan. |
| `c535b30` T411 | `assets/sprites/effects/jefe/boss_burst.png`, `boss_crack.png`, `boss_card_frame.png` (+ `.import`) | REHACER | Entraron en el commit de T411 aunque son del jefe. Hay que sacarlos del cherry-pick. |
| `0a7619c` T412 | `scenes/effects/boss_entrance_burst.gd`, parte de `tests/test_boss_entrance_hud.gd`, nota en `03-tareas.md` | REHACER | Integra destello y grieta del concepto viejo. |
| `7d2945f` T413 | `scenes/ui/boss_entrance_card.gd`, `scripts/data/boss_entrance_config.gd`, `data/ui/entrada_jefes.json`, parte de `test_boss_entrance_hud.gd` | REHACER | Marco 9-slice del cartel de 720×120; cambia datos y config del cartel que la nueva M66 reemplaza. |
| `7d2945f` T413 | `tests/test_save_backup.gd.uid` | RETIRAR | Archivo generado que se coló; en `main` no existe (T433 sacó los parecidos). No debe entrar. |
| `53bcf26` T414 | `.import` de `upgrade_l2/l3` (`process/size_limit` 384), `upgrade_effect.gd` (escala ×2), `test_upgrade_fx.gd`, D-176, RF-643 (parte de mejoras) | CONSERVAR con reservas | Reducción a media resolución de los atlas de mejora. La mejora de tiempo **no está demostrada** (la medición se hizo con la máquina saturada): conservar el cambio solo si Lucas acepta el recorte de calidad sin medición limpia; si no, dejar los atlas a tamaño original (variante de rescate B, §5). |
| `53bcf26` T414 | `boss_burst.png.import` (512), `boss_entrance_burst.gd`, parte de jefe de RF-643/D-176/plan, tests de jefe | REHACER | Optimiza el atlas viejo del jefe. |
| `53bcf26` T414 | `tools/perf_test.gd` | CONSERVAR la parte genérica; REHACER `entrada_jefe` | Mejoras reales: una sola partida, semilla fija, ventana activa simétrica, preferencias solo en memoria, error si no se construyen las 60 torres, `available_towers`. Sirve para medir mejoras. La rama `entrada_jefe` (4,9 s / 1,6 s, `_boss_entrance_types`) depende del cartel viejo. Hay que revisar a mano el archivo al cherry-pick (no se puede partir limpio por commit). |
| `584faf0` T415 | `CHANGELOG.md`, `CONTENIDO.md`, `README.md`, `ONBOARDING.md` | REHACER | Hablan de mejoras **y** de jefe; hay que reescribirlos para que M71 quede solo con mejoras. |
| `cd025ad` T416 | `tests/test_boss_entrance_hud.gd` (tolerancia de redondeo del cartel), nota en `03-tareas.md` | REHACER | Solo toca tests del cartel viejo. |
| `5d1a449` T417 | Merge de `main` (documentos, `art/t372-muestras`, `.github/pull_request_template.md`, etc.) | RETIRAR (no se rescata) | Es contenido de `main` ya presente; no se cherry-pickea, la rama de rescate nace de `main`. |
| `aa812f1` (este T452) | Merge de `origin/main` sobre la rama del PR | Solo informativo | Sin conflictos; no afecta al PR #22 real. |

## 4. Qué debe rehacerse antes de que Lucas decida

1. **Todo lo del jefe** (RF-626, RF-627, parte de RF-628/RF-629/RF-643, D-165 en su parte de jefe, T412, T413, `assets/sprites/effects/jefe/*`, `art/t367-muestras/`): la nueva M66 (pausa, pantalla completa, 3 o 5 s) cambia el concepto, así que este arte e integración quedan atados a una decisión pendiente (ver el frente E de la matriz). **PENDIENTE DE LUCAS.**
2. **Documentos:** M71 debería quedar solo como «mejoras»; D-165 y D-176 deben partirse en lo que sigue vigente y lo retirado, sin renumerar. Los números RF-626, RF-627 y los tramos de jefe de RF-628/629/643 se marcan «retirados» (no se reusan).
3. **`tests/test_save_backup.gd.uid`:** retirar.
4. **Medición (RF-629):** sigue sin cumplirse con evidencia limpia. Antes de afirmar «≤ 1 ms», hay que correr `perf_test -- mejoras` contra `-- mejoras sin_fx` con la máquina libre y anotar resolución, hardware, `uptime`/carga y build. T364 sigue abierta; la prueba en celular real también.
5. **Peso de la rama:** ~100 archivos de `art/` (fuentes, GIF, PNG de revisión) vienen en el PR; para el rescate alcanza con `art/t362-muestras/` si Lucas quiere esa carpeta en `main`.

## 5. Plan de rescate propuesto (NO ejecutado)

Rama nueva `feature/t4xx-rescate-mejoras-m71` **desde `origin/main`** (número de tarea lo asigna el agente de spec; libre desde T447). Comandos propuestos, para revisar:

```bash
git worktree add -b feature/t4xx-rescate-mejoras-m71 <carpeta> origin/main
# 1. Arte aprobado de T362 (solo la carpeta de mejoras)
git checkout d40cdb3 -- art/t362-muestras
# 2. T411 sin los PNG del jefe ni su .import
git cherry-pick -n c535b30
git rm --cached -q assets/sprites/effects/jefe/*   # y borrar los archivos del árbol
#    queda: mejora/upgrade_l2|l3.png(+.import), upgrade_effect.gd, effects_layer.gd, test_upgrade_fx.gd
# 3. (Opcional, variante A) T414 solo la parte de mejoras: .import de los dos atlas,
#    upgrade_effect.gd (escala x2), test_upgrade_fx.gd, y tools/perf_test.gd tomado a mano
#    quitando lo de entrada_jefe. Variante B: omitir este paso y dejar los atlas a tamaño original.
# 4. Documentos: reescribir M71/RF-625/RF-628/RF-629 (solo mejoras) y D-165/D-176 recortadas;
#    marcar RF-626/627 y los tramos de jefe como «retirados»; NO tomar el 03-tareas.md ni los
#    CHANGELOG/CONTENIDO/README/ONBOARDING del PR tal cual.
# 5. No traer: 7d2945f, 0a7619c, cd025ad, test_save_backup.gd.uid, art/t367-muestras.
```

Después: `godot --headless --import`, `git checkout -- assets` de lo no tocado a propósito, GUT completo (mirar `SCRIPT ERROR`), y recién ahí PR. Orden sugerido: primero decidir la nueva M66 (frente E), después rescatar; el rescate de mejoras no depende de ella.

**Decisiones pendientes de Lucas (propuestas, sin ejecutar):**
- **P-1:** ¿cerrar el PR #22 como «reemplazado» cuando exista la rama de rescate? Alternativas: (a) cerrarlo; (b) dejarlo draft como archivo; (c) rehacerlo recortado en su propia rama. Recomendación: (a), solo con tu OK.
- **P-2:** ¿se conserva la importación a media resolución de los atlas de mejora (RF-643/D-176) sin medición limpia? Alternativas: A conservar, B tamaño original hasta medir. Recomendación: B hasta tener una medición con la máquina libre.
- **P-3:** ¿se guarda `art/t367-muestras/` (referencia del concepto viejo) o se descarta? Recomendación: descartar de `main`, queda en la rama del PR.

## Decisiones de Lucas (2026-10-23)

> Registradas por Claude a partir de las respuestas de Lucas en la sesión. **Todavía no son D ni RF** y nada está implementado; los números de D/RF los fija la tarea de spec. Lo que dice «a aclarar» queda abierto.

1. **P-1:** el PR #22 se **cierra como «reemplazado»** cuando exista la rama de rescate con solo lo aprobado.
2. **P-2:** se **conserva la importación a media resolución** de los atlas de mejora, **contra la recomendación** de importar normal hasta medir. **No hay medición limpia:** T364 sigue abierta y se mide con la máquina libre.
3. **P-3:** se **descarta** `art/t367-muestras/` y el arte del jefe viejo (quedan en la historia de git).
4. **T350:** se trae **solo el informe** `T350-analisis-sin-mejoras-y-8-9.md` en un PR aparte (arregla referencias colgadas); **T436: se descarta**. No se borra ninguna rama.
