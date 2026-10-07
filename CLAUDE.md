# JuegoA (TDv1)

Tower defense 2D en **Godot 4.7** con **GDScript**, hecho con **spec primero**. Lucas escribe en español (rioplatense): **todo lo que se le dice y se escribe en los documentos va en español**, con explicaciones claras y detalladas. Nombres de código, archivos y escenas, en inglés.

## Cómo se corre

Godot está en `C:\Tools\Godot\`. En PowerShell alcanza con `godot`; desde Git Bash hay que llamar a `/c/Tools/Godot/godot.cmd` (ahí `godot` no se encuentra). Usar `godot.cmd` (el que muestra los mensajes en la terminal); **no** renombrar `Godot_v…_console.exe` a `godot.exe` (ver `ONBOARDING.md`). Todo desde la carpeta del proyecto:

```bash
godot --headless --import                                              # antes de los tests si hay clases (class_name) o archivos nuevos
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit   # todos los tests de GUT
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_x.gd -gexit   # uno solo
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix level=3  # el bot de balance (uso en el encabezado del archivo)
godot --headless --path . --export-release "Windows (pruebas)" build/JuegoA_pruebas.exe   # ejecutable con el modo de pruebas
```

- Un test que pasa pero imprime `SCRIPT ERROR` **es un fallo**: mirar la salida completa, no solo el resumen.
- Jugar con el modo de pruebas desde el editor: argumento `-- --pruebas` (spec §10.2).
- **`--import` reescribe a veces los SVG de `assets/sprites/`** (cambia saltos de línea). Antes de cada commit, mirar `git status` y devolver con `git checkout -- assets` lo que no se tocó a propósito.

## Cómo se trabaja (SDD)

Todo cambio pasa por: **spec** (`specs/01-spec.md`, requisitos `RF-xxx` con criterio "Dado / Cuando / Entonces") → **decisión** (`specs/04-decisiones.md`, `D-0xx`, con el porqué y las alternativas descartadas) → **plan** (`specs/02-plan-tecnico.md`) → **tareas** (`specs/03-tareas.md`, `Txxx`, con "Hecho cuando" y, al terminar, `[x]` y un "Resultado" honesto: qué se hizo, qué se probó y qué **no**) → **código y tests** → commit.

- Los números de `RF` y de `D` **no se reusan ni se reordenan**: siempre el siguiente.
- Una tarea = un commit, con el mensaje `Txxx: …`. Al terminar una tarea con su criterio cumplido y los tests en verde, se hace commit y `git push` sin pedir permiso (Lucas lo pidió así); si el push falla, avisarle, no forzarlo.
- Si el usuario pide mostrar la spec antes de programar, **se espera su OK**.
- Cuando algo ya escrito cambia (un tamaño, una regla, una tecla), se actualiza en todos los lugares donde aparece: spec, plan, `CONTENIDO.md`, `README.md`, `ONBOARDING.md` y `CHANGELOG.md`.

## Sugerencias de Claude

Las ideas que propongo **por mi cuenta** (nadie las pidió) **no se implementan**: se anotan en `specs/01-spec.md` §13, sección **"Sugerencias de Claude (consultar antes de implementar)"**, y se le consultan a Lucas. Una idea que sí pidió Lucas va al backlog (§13) o directo a la spec.

## Reglas por carpeta

Viven en `.claude/rules/` y se cargan solas según el archivo que se edita. No se repiten acá:

| Archivo | Cubre |
|---|---|
| `.claude/rules/gdscript.md` | tabuladores, tipos estáticos, números en `data/`, señales hacia arriba, trampas de Godot |
| `.claude/rules/tests.md` | cómo se corren y se escriben los tests de GUT (nada que cambie de escena, guardados `user://test_*.json`) |
| `.claude/rules/specs.md` | formato y reglas de los documentos de `specs/` |
| `.claude/rules/datos.md` | los archivos de `data/` (torres, enemigos, niveles, artículos de la Wiki) |
| `.claude/rules/arte.md` | los dibujos SVG de `assets/sprites/` (estilo: `specs/05-guia-de-arte.md`) |

## Dónde está cada cosa

La **constitución** (`specs/00-constitucion.md`, principios P1 a P10) manda sobre todo lo demás. `README.md` explica el proyecto, `ONBOARDING.md` cómo instalarlo y probar cada hito, `CONTENIDO.md` qué datos se pueden agregar sin programar, `CHANGELOG.md` lo nuevo para quien juega. `specs/06-monsters-canons-3d.md` es el concepto de la segunda entrega en 3D y el relevamiento de lo pendiente en la V1: consultarlo antes de planificar qué sigue.

## Ramas Git
Lucas, 2026-10-03: usar siempre el prefijo `feature/` para ramas nuevas; nunca `codex/`. La instrucción del usuario prevalece sobre el prefijo sugerido por la app.
