# T523 · 🎨 Muestras dimensionales para seis adornos de M79

- **Ejecutor:** Codex `gpt-6.1-sol`, esfuerzo medio; revisión de Sonnet.
- **Depende de:** T522; dirección de arte de decoración de mapa T277 y guía `specs/05-guia-de-arte.md` §4.
- **Refs:** RF-712 a RF-714, D-210. **Rama:** `feature/t523-muestras-adornos-m79`, desde `origin/main`; si T522 aún no está en `main`, abrir contra `main` y explicar en el cuerpo que T522 (#<PR>) debe mergearse antes.
- **Compuerta:** entrega de propuestas solamente. Lucas revisa y aprueba cada pieza antes de T524. No integra assets al juego.

## Leer

CLAUDE.md, `~/.agents/AGENTS.md`, `specs/00-constitucion.md`, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` §4, M79/RF-712 a RF-714 en `specs/01-spec.md`, D-210 y el inventario `art/m79-inventario/inventario.md` si está disponible.

## Objetivo

Proponer los seis adornos que Lucas agregó a M79 el 2026-10-26: cactus, roca roja, columna, bloque, estatua y campamento vacío. Las muestras muestran cómo cada forma convive con la decoración dimensional actual y con los casos de uso de sus biomas.

## Alcance

- Crear muestras editables de los seis motivos en estética T277: volumen pintado, luz suave arriba a la izquierda, alfa limpio y sombra de apoyo discreta.
- Entregar PNG RGBA de 128×128 mostrados a 64×64, fuentes, `prompts.md`, `manifest.json` y herramientas de render si corresponden.
- Incluir hoja a 220 px y a 34 px, más composiciones en capturas de mapas apropiados para desierto, volcán/ruinas y campamento de niveles 14/15. Identificar composiciones como muestras, no como integración.
- Lucas elige/aprueba cada diseño visualmente; puede rechazar o pedir ajustes por separado.

No cambiar `assets/`, `scripts/`, escenas, `data/levels/`, leyendas, temas, mapas, grillas ni CHANGELOG. No elegir por Lucas ubicaciones nuevas en niveles ni integrar arte final. Si una composición requiere asumir un nivel o bioma no explicitado en los datos, señalarlo en el informe y no presentarlo como decisión.

## Hecho cuando

Están las seis propuestas con sus fuentes y procedencia, hoja en tamaños de revisión y composiciones pertinentes; el informe lista diferencias, riesgos de lectura y archivos; no hay cambios al juego. Lucas tiene un punto claro para aprobar, rechazar o pedir cambios por pieza.

## Verificación

Revisión visual de cada PNG a tamaño de juego y de muestra; revisar procedencia y `git diff --check`. No ejecutar Godot/GUT, porque la tarea no toca el proyecto jugable. No afirmar prueba en teléfono ni rendimiento.

## Frenar si

Una forma se confunde con una torre, enemigo, señal o casilla construible; el arte exige cambiar tema, leyenda, grilla o canon; no se puede identificar el uso de una muestra sin inventar una ubicación.
