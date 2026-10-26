# T505 · 🎨 Muestras del glifo H gótico y de los tipos de marca

- **Ejecutor:** Codex (`gpt-6.1-sol`, esfuerzo medio) · muestras (propuestas, no arte final); Sonnet o Gemini si hace falta. La elección es de Lucas.
- **Depende de / compuerta:** 🚦 T503 revisada y T504 hecha. Lucas pidió **explorar** el glifo; **adoptarlo como canon necesita su OK escrito (T506)**. **Cambio de canon A → H: no se adopta nada con esta tarea.**
- **Refs:** RF-717, RF-718, RF-719, D-212. **Rama:** `feature/t505-muestras-glifo-marcas`, desde `origin/main`; un commit `T505: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/00-constitucion.md, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` (§4), M80 en `specs/01-spec.md` (RF-716 a RF-719 y las preguntas abiertas), D-212 (con la lista de menciones del símbolo A) y `specs/10-universo.md` (§5 y §6).

## Objetivo y alcance

Proponer el glifo de los Moradores como una **«H» rara de estilo gótico** (dirección de Lucas, «quizá») y los **tipos de marca**. **Estética (requisito de Lucas, 2026-10-25, vigente):** la actual de `main` (atlas de Cántaro M76/T471, postes T437/T475, decoración dimensional renderizada T277, UI vigente), no la vieja: nada de SVG plano de T260. PNG RGBA de 128×128 mostrado en 64×64, luz arriba a la izquierda, sombra de apoyo discreta, dentro de la huella de una casilla.

- **Glifo:** 3 variantes. Debe leerse como **signo tallado, no como una letra de fuente** (la A de PR #95 fracasó por eso), no parecerse a una lápida o a una cruz, y reconocerse a **34 px sobre la roca**. Es siempre el mismo en todos los tipos (una marca «se repite, siempre igual», `10-universo.md` §6).
- **Tipos:** al menos **grabada** (decal sobre las rocas de T504), **estela** (piedra baja exenta) y **pintada** (sobre muro o suelo); se pueden proponer otros, siempre con huella de una casilla.
- Probar con y sin el poste de campaña del nivel (T475) y recordar que en 8 y 9 `(0, 4)` está frenada.
- **Fuentes y procedencia (RF-719):** guardar en la carpeta `sources/` las fuentes editables, `prompts.md`, `manifest.json` y el empaquetador si hace falta; el informe dice quién produjo cada pieza (modelo, esfuerzo, fecha) y con qué herramienta.

## Archivos (propietario único)

Solo `art/m80-marcas/`. No se toca `assets/`, `scripts/`, `data/`, `specs/` ni `art/m80-rocas/` (se lee).

## Hecho cuando

Hay 3 variantes del glifo y al menos 3 tipos de marca, hoja a 220 y 34 px sobre rocas de T504, y una captura de un nivel con el arte compuesto fuera del juego; sin integrar. El informe dice qué se probó y qué no.

## Frenar si

La muestra exige cambiar el significado del símbolo, un JSON o la grilla; el glifo parece texto o una lápida; falta T504.
