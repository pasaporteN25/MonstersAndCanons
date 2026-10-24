# T478 · Integrar franjas por terreno sin moverlas con zoom

- **Ejecutor:** Sonnet · integración; Codex assets aprobados.
- **Depende de / compuerta:** T476 integrada con arquitectura aprobada explícitamente por Lucas, T477 aprobada por terreno, T460 aprobada; coordinar Game/cámara con T461/T464/T475.
- **Refs:** RF-700/RF-701/RF-702/RF-707. **Tamaño:** una sesión; dividir si el alcance real la supera.
- **Rama:** `feature/t478-integrar-franjas-tematicas` desde origin/main actualizado, worktree propio; un commit `T478: …`, PR a main, Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/tareas/README.md, constitución, M77 (RF-699–707), D-204–206, plan técnico M77, informe T450 entero y ficha T454 (desde main cuando se integre #57; lectura remota hasta entonces, sin editar ese PR).

## Objetivo y alcance

Mapear tema del nivel a recurso aprobado, fijo en pantalla y con recorte runtime. Rellenar exterior y márgenes internos sin cambiar mapa/HUD. Respaldo liso si falta tema/recurso y fuera de nivel. Tope zoom 1,0, input intacto y P6; sin alterar datos jugables.

## Archivos previstos

host de presentación, data/ui/catalogo de fondos y assets aprobados; escenas Game/MapBackdrop según integración y tests. Leer reglas por carpeta antes de editar y asignar propietario único de cada archivo compartido.

## Hecho cuando

Fondos aprobados visibles en franjas sin movimiento al acercar/desplazar; sin huecos ni deformación, cámara máxima 1,0 y mapa/input idénticos.

## Verificación

Tests de catálogo/respaldo/zoom/posición independiente y suite GUT. Capturas por terreno/aspecto mínimo/máximo zoom; teléfono real queda T454/T238. Versionar cada `.uid` de test propio. Tras import, revertir únicamente assets no tocados a propósito; salida 139 se relanza y registra. Un test con SCRIPT ERROR es fallo. Capturas fuera del repo salvo las del PR; resolución/hardware/uptime/build obligatorios para afirmar rendimiento.

## Frenar si

Falta aprobación funcional/de arte/medición que la ficha exige; la solución pide expandir mapa/HUD, cambiar mecánicas/canon/balance o descartar guardados; otro agente edita los mismos archivos. Informar el límite y seguir solo con trabajo independiente autorizado.
