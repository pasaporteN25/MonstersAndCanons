# T486 · 📜 Spec del descubrimiento del atlas por zonas

- **Ejecutor:** Sonnet · especificación (solo documentos).
- **Depende de / compuerta:** ninguna integración. 🚦 **Lucas revisa y aprueba** la spec (RF-709 a RF-711, D-209) antes de T487/T488.
- **Refs:** RF-709 a RF-711, D-209, M78; RF-111, RF-688, RF-689, RF-691, RF-695; T485. **Rama:** `feature/t486-descubrimiento-spec`, desde `origin/main`; un commit `T486: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/00-constitucion.md, M76 en specs/01-spec.md (RF-687 a RF-698) y D-198 a D-203, `specs/tareas/T485-atlas-biomas-zonas.md`, `art/t485-atlas-biomas/` y el modelo `scripts/logic/campaign_map.gd`.

## Objetivo y alcance

Dejar por escrito la regla del atlas que se revela por grupos de cinco niveles, sin cambiar el acceso N→N+1. Debe distinguir **descubierto** (zona del atlas), **desbloqueado** (nivel jugable) y **conquistado** (insignia). Documentar guardados viejos, modo de pruebas, alternativas descartadas y las preguntas abiertas para Lucas. No se escribe código ni arte.

## Archivos

`specs/01-spec.md` (M78, B-61), `specs/02-plan-tecnico.md`, `specs/03-tareas.md` (solo la entrada T486), `specs/04-decisiones.md` (D-209), esta ficha y las de T487/T488.

## Hecho cuando

Lucas puede responder las cuatro preguntas de M78 y aprobar o corregir la regla. Hasta entonces la spec es propuesta.

## Verificación

Revisión documental. No Godot ni tests. Números verificados libres en todas las ramas antes de reservarlos.

## Frenar si

Lucas cambia la regla (por ejemplo, descubrir por conquista) o pide abrir niveles por grupos: eso contradice RF-111 y requiere una decisión nueva, no una edición silenciosa.
