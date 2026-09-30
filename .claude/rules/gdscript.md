---
paths:
  - "scripts/**/*.gd"
  - "scenes/**/*.gd"
  - "tools/**/*.gd"
  - "tests/**/*.gd"
---

# Reglas de GDScript en este proyecto

Vienen de la constitución (`specs/00-constitucion.md`) y de errores que ya nos pasaron.

## Formato
- **Se sangra con tabuladores**, nunca con espacios. Para editar un archivo con tabuladores usá la herramienta Edit (conserva los tabuladores). No uses `sed` con acentos graves ni scripts que conviertan tabuladores en espacios.
- **Todo lleva tipo** (P5): variables, parámetros y retornos (`var speed: float = 1.5`, `-> void`).
- **Idioma (P9):** comentarios y textos para el jugador en **español**; nombres de variables, funciones, archivos y escenas en **inglés**.

## Diseño
- **Los números de balance viven en `data/`** (P2), no en el código. Una constante en el código solo si es de interfaz o de formato (por ejemplo, el tamaño de una casilla).
- **Señales hacia arriba, llamadas hacia abajo** (P6): un hijo nunca busca a su padre; emite una señal.
- La lógica importante va en funciones que **no dependen de la escena** (P10), en `scripts/logic/`, para poder probarla sin abrir ventanas.

## Trampas de Godot que ya nos mordieron
- Una clase hija con su propio `_init` **tiene que llamar a `super()`**.
- No poner a una variable el nombre de un método virtual (`_input`, `_process`…).
- Las lambdas capturan las variables locales **por valor**: para cambiar algo desde una lambda, usar un contenedor (array, diccionario).
- Comparar `StringName` con `<` **no ordena alfabéticamente**: usar `String(a) < String(b)`.
- Para leer JSON usar `JSON.new().parse(...)`, no `JSON.parse_string` (imprime errores del motor que rompen los tests).
- Un valor entero de JSON llega como `float` (`2` → `2.0`): convertir antes de mostrarlo.
- Los scripts de `tools/` (se corren con `-s`) **se compilan antes que los autoloads**: no pueden nombrar `GameFlow`, `SaveManager` ni `Audio`, ni declarar variables de tipo `Game`.
- Una clase nueva (`class_name`) no se ve hasta que Godot la importe: correr `godot --headless --import` antes de los tests.
- Un enemigo o torre exportado aparece como `*.tres.remap`: para listar una carpeta de recursos, quitar el `.remap` (ver `LevelFile.enemy_ids()`).
