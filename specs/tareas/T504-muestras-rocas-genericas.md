# T504 · 🎨 Muestras de rocas genéricas en tres colores

- **Ejecutor:** Codex (`gpt-6.1-sol`, esfuerzo medio) · muestras (propuestas, no arte final); Sonnet o Gemini si hace falta. La elección es de Lucas.
- **Depende de / compuerta:** 🚦 T503 revisada por Lucas. **La elección es de Lucas (T506).**
- **Refs:** RF-716, RF-719, D-212. **Rama:** `feature/t504-muestras-rocas`, desde `origin/main`; un commit `T504: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/00-constitucion.md, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` (§4), M80 en `specs/01-spec.md` (RF-716 a RF-719 y las preguntas abiertas), D-212 (con la lista de menciones del símbolo A) y `specs/10-universo.md` (§5 y §6).

## Objetivo y alcance

Producir **2 o 3 modelos de roca realistas** (forma y volumen distintos) en **tres colores** para usarse en distintos mapas. **Estética (requisito de Lucas, 2026-10-25, vigente):** la actual de `main` (atlas de Cántaro M76/T471, postes T437/T475, decoración dimensional renderizada T277, UI vigente), no la vieja: nada de SVG plano de T260. PNG RGBA de 128×128 mostrado en 64×64, luz arriba a la izquierda, sombra de apoyo discreta, dentro de la huella de una casilla.

- **Sin ningún símbolo ni grabado en la roca:** la marca es de T505.
- Los tres colores de partida: gris calizo (pradera y bosque), rojizo de arenisca (desierto) y oscuro (ruinas); la roca nevada del 13 es la ya elegida en el PR #96 y no se rehace. Lucas decide los colores finales y su reparto.
- Que dos rocas vecinas del mismo color no se vean repetidas (modelos y rotaciones/reflejos que no cambien la luz).
- Nada de lápidas ni de formas que se lean como torre o como camino (guía §4).
- **Fuentes y procedencia (RF-719):** guardar en la carpeta `sources/` las fuentes editables, `prompts.md`, `manifest.json` y el empaquetador si hace falta; el informe dice quién produjo cada pieza (modelo, esfuerzo, fecha) y con qué herramienta.

## Archivos (propietario único)

Solo `art/m80-rocas/` (fuentes, PNG, hojas y capturas). Nadie más escribe ahí; no se toca `assets/`, `scripts/`, `data/` ni `specs/`.

## Hecho cuando

Hay 2 o 3 modelos en tres colores, hoja de contacto a 220 y 34 px sobre el suelo de pradera, bosque, desierto, nieve y ruinas, y una captura sobre el mapa de un nivel de la tabla de M80 con el arte puesto fuera del juego; sin integrar. El informe dice qué se probó y qué no (sin teléfono real, sin rendimiento).

## Frenar si

El estilo cae en SVG plano viejo; la muestra exige un JSON o la grilla; Lucas aún no revisó T503.
