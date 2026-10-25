# T493 · 🎨 Muestras de los pinos nevados

- **Ejecutor:** Codex (`gpt-6.1-sol`, esfuerzo medio) · muestras (propuestas, no arte final); Sonnet o Gemini si hace falta. La elección es de Lucas.
- **Depende de / compuerta:** 🚦 T490 aprobada por Lucas y T491 hecha. **La elección es de Lucas (T495).**
- **Refs:** RF-713 (b), RF-714, D-210. **Rama:** `feature/t493-muestras-pinos-nevados`, desde `origin/main`; un commit `T493: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/00-constitucion.md, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` (§4), M79 en `specs/01-spec.md` (RF-712 a RF-714 y las preguntas abiertas), D-210 y `specs/10-universo.md` (§4 y §6).

## Objetivo y alcance

**Estética (requisito de Lucas, 2026-10-25):** toda muestra sigue la estética **actual** de `main` (atlas de Cántaro M76/T471, postes T437/T475, decoración dimensional renderizada T277, UI vigente), **no la vieja**: no se entrega una variante plana SVG de T260. Producir muestras para que Lucas elija, sin tocar el juego. Formato: PNG RGBA de 128×128, luz arriba a la izquierda, sombra de apoyo discreta, dentro de una casilla de 64×64; se compone en la herramienta de captura, no en `assets/sprites/map/`.

Variantes de pino y abeto (y de la roca nevada si Lucas lo confirma, pregunta 4) que se lean como árbol nevado y como «acá no se construye»; verdes y blancos que no compitan con la Araña ni la Cría (verdes azulados) sobre la nieve. Entre 2 y 3 variantes por dibujo.


## Archivos (propietario único)

Solo `art/m79-muestras/nieve/` (fuentes, PNG, hojas y capturas). Nadie más escribe ahí; no se toca `assets/`, `scripts/`, `data/` ni `specs/`.

## Hecho cuando

Hay variantes de pino, abeto y roca nevada, hoja a 220 y 34 px con los enemigos de la guía sobre el suelo `nieve`, y una captura del nivel 13; sin integrar. El informe dice qué se probó y qué no (sin teléfono real, sin rendimiento).

## Frenar si

Falta T491 o su OK; la muestra exige cambiar el canon o un JSON de nivel; el estilo cae en SVG plano viejo.
