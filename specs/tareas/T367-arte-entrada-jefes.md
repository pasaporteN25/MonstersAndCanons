# T367 · Muestras de ilustración y fondos de la presentación de jefes

> **Estado:** pendiente del OK de Lucas a T457 y de fijar el estilo en la guía de arte. No producir arte final ni copiar nada a `assets/` sin aprobación escrita. El concepto anterior de destello, grieta y cartel quedó reemplazado.

- **Ejecutor:** Codex, solo para arte después de fijar el estilo. **Depende de:** T457 aprobado y guía de arte aplicable. **T243:** define el jefe supremo del nivel 15; no dibujar ese fondo antes.
- **Compuerta humana:** Lucas revisa y aprueba las muestras antes de integrarlas.

## Alcance

Preparar muestras para una secuencia a pantalla completa animada por código sobre ilustraciones quietas:

1. Una ilustración y un fondo propios para el Jefe actual (`boss`).
2. Una ilustración y un fondo propios para el Coloso (`colossus`).
3. El jefe supremo del nivel 15 queda fuera de esta entrega hasta que T243 defina el personaje; T463 tomará ese arte después.

No diseñar un destello en el mapa, grieta, marco de cartel ni animación cuadro a cuadro. No modificar retratos ya aprobados sin autorización expresa. La presentación no usa marca de entrada en el mapa.

## Lecturas y referencias

Leer `specs/tareas/README.md` §6, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` y M66 en `specs/01-spec.md` (RF-666 a RF-673). Revisar D-187 a D-191 y los retratos oficiales existentes. Confirmar en el repo rutas, `.uid` y estado real de los assets antes de escribirlos en la entrega; no inferir existencia de archivos por informes anteriores.

## Entregables de muestra

- Carpeta `art/jefes-m66/` fuera de `assets/`, con fuentes originales, `prompts.md`, `manifest.json` y una página HTML que compare cada retrato con su fondo y la composición a pantalla completa.
- Composición estática en 16:9 y en la interfaz celular simulada a 1280×720. Incluir título, nombre y frase como texto de muestra para revisar jerarquía, contraste, recorte y legibilidad; el movimiento se implementa por código y se valida en T461.
- Registrar dimensiones, formato, tamaño en disco y cualquier recorte. No afirmar rendimiento ni calidad en teléfono real.

## Pasos

1. Esperar el OK de Lucas a T457 y confirmar el estilo aplicable.
2. Verificar en el repo los retratos y sus licencias/estado de aprobación.
3. Crear muestras fuera de `assets/`; no reemplazar ni editar assets aprobados existentes.
4. Mostrar la comparación a Lucas y registrar su respuesta en `specs/03-tareas.md`.
5. Solo después del OK, integrar los fondos e ilustraciones aprobados en una tarea posterior, sin modificar el comportamiento de la secuencia.

## Hecho cuando

Las muestras del Jefe y Coloso, fuentes, prompts, manifiesto y comparaciones están listas fuera de `assets/`; Lucas aprobó por escrito; la aprobación y los tamaños están anotados en el tablero. El fondo del jefe supremo no se considera parte de T367 y requiere T243/T463.

## Frenar si

- La guía no define un estilo compatible con ilustraciones de pantalla completa.
- Para adaptar un retrato aprobado hace falta cambiar su canon, pose o diseño.
- La composición no se lee en las dos relaciones de aspecto solicitadas.
- Se pretende producir o integrar el jefe supremo antes de T243.
