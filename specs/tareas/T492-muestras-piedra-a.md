# T492 · 🎨 Muestras de la piedra con la A

> **Descartada (Lucas, 2026-10-26).** Las muestras del PR #95 no se integran: la A salía como letra tipográfica sobre una lápida. Reemplazada por M80: rocas genéricas (T504), glifo H y marcas (T505). Ver D-212 y la entrada de T495. No hacer esta tarea.

- **Ejecutor:** Codex (`gpt-6.1-sol`, esfuerzo medio) · muestras (propuestas, no arte final); Sonnet o Gemini si hace falta. La elección es de Lucas.
- **Depende de / compuerta:** 🚦 T490 aprobada por Lucas y T491 hecha. **La elección es de Lucas (T495).**
- **Refs:** RF-713 (a), RF-714, D-210. **Rama:** `feature/t492-muestras-piedra-a`, desde `origin/main`; un commit `T492: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/00-constitucion.md, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` (§4), M79 en `specs/01-spec.md` (RF-712 a RF-714 y las preguntas abiertas), D-210 y `specs/10-universo.md` (§4 y §6).

## Objetivo y alcance

**Estética (requisito de Lucas, 2026-10-25):** toda muestra sigue la estética **actual** de `main` (atlas de Cántaro M76/T471, postes T437/T475, decoración dimensional renderizada T277, UI vigente), **no la vieja**: no se entrega una variante plana SVG de T260. Producir muestras para que Lucas elija, sin tocar el juego. Formato: PNG RGBA de 128×128, luz arriba a la izquierda, sombra de apoyo discreta, dentro de una casilla de 64×64; se compone en la herramienta de captura, no en `assets/sprites/map/`.

La **A es canon de los Moradores**: no cambia su significado ni su lectura como señal, y se usa la misma A en `roca_marcada` y en `simbolo_ruina` (la segunda, en piedra de ruina más vieja y quebrada), salvo que Lucas elija una sola (pregunta 2). Mismo tamaño de huella (pregunta 3). Entre 2 y 3 variantes de ejecución por dibujo (material, volumen, profundidad del trazo), no una A distinta. Probar también la señal con el poste de campaña encima (T475) para el nivel 8/9, casilla `(0, 4)`.


## Archivos (propietario único)

Solo `art/m79-muestras/piedra-a/` (fuentes, PNG, hojas y capturas). Nadie más escribe ahí; no se toca `assets/`, `scripts/`, `data/` ni `specs/`.

## Hecho cuando

Hay 2 o 3 variantes por dibujo, A reconocible a 34 px y la misma en ambos, hoja de contacto a 220 y 34 px sobre el suelo de pradera, bosque, desierto, nieve y ruinas, y una captura sobre el mapa de un nivel que use cada dibujo; sin integrar. El informe dice qué se probó y qué no (sin teléfono real, sin rendimiento).

## Frenar si

Falta T491 o su OK; la muestra exige cambiar el canon o un JSON de nivel; el estilo cae en SVG plano viejo.
