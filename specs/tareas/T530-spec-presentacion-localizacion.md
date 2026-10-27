# T530 · Especificar pulido de presentación e idioma inglés

- **Ejecutor:** Sonnet 5.5 · **Tamaño:** pequeño · **Tipo:** 📜 documentos.
- **Depende de:** ninguna.
- **Compuerta:** Lucas revisa y mergea antes de empezar T531–T534.

## Leer

- `CLAUDE.md`
- `specs/00-constitucion.md`
- `specs/01-spec.md` RF-111, RF-459 a RF-461, RF-645, RF-688, RF-699 a RF-702 y RF-723
- `specs/04-decisiones.md` D-215 y D-216
- `specs/02-plan-tecnico.md` M77, M81 y M82
- `specs/03-tareas.md` M82
- `specs/tareas/README.md`

## Objetivo

Dejar criterios comprobables para los cuatro pedidos de Lucas del 2026-10-27, preservando la navegación, las reglas y el marco 2D actuales.

## Alcance

- Registrar RF-724 a RF-727 y D-217, con decisiones ya expresadas por Lucas.
- Preparar las tareas T531–T534 y sus dependencias.
- Crear sus fichas delegables.
- Actualizar spec, decisión, plan, tablero e índice de fichas.
- Conservar como antecedentes los requisitos sustituidos y anotar fecha/motivo.

## Fuera de alcance

- Código, pruebas, arte, traducciones finales o música.
- Cambiar mecánicas, progresión, mapas, guardados de campaña, balance o `SAVE_VERSION`.
- Abrir más de una tarea de especificación en paralelo.

## Hecho cuando

- Las tarjetas listan solo niveles iniciables y el mapa conserva la inspección de bloqueados.
- La confirmación de salida se limita a título, botones y una advertencia opcional.
- Las franjas existentes pierden protagonismo sin alterar el viewport jugable.
- El idioma es español por defecto y se puede elegir Inglés para todo texto visible del juego.
- El inventario y traducción completa quedan como tareas separadas y verificables.
- `git diff --check` pasa; el PR es solo documental y va contra `main`.

## Verificación

Revisar RF y referencias en los documentos afectados, buscar que los números nuevos no estén usados en `origin/main` ni PR abiertos y correr `git diff --check`. No correr Godot/GUT: no se toca código.

## Frenar si

Alguno de los pedidos requiere alterar progreso, interacción aprobada, guardado de campaña, canon o más idiomas. No ampliar alcance sin Lucas.
