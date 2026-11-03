# T579 · Revisión integrada de M89 y lista para el teléfono

- Ejecutor · Sonnet · esfuerzo medio
- Depende de · T563 a T574 y T578 (no de T575 a T577) · Compuerta · ninguna · Tamaño · Mediano

## Leer

`specs/tareas/M89-orquestacion.md`, M89 en `specs/01-spec.md` y los Resultados de cada tarea en `specs/03-tareas.md`.

## Objetivo

Comprobar que todo funciona junto y darle a Lucas una lista corta para probarlo en un teléfono.

## Alcance

**Sí:** arreglos chicos de integración, `README.md`, `ONBOARDING.md`, `CONTENIDO.md`, `CHANGELOG.md`, spec y plan donde haya quedado algo desactualizado, un informe `specs/tareas/informes/T579-revision-m89.md` y una sección en `specs/tareas/informes/PENDIENTES-LUCAS.md`.

**No:** funciones nuevas. Un problema más grande que un ajuste se informa como tarea aparte.

## Pasos

1. Recorrer cada `RF` de M89 con su criterio «Dado / Cuando / Entonces». Marcar con evidencia: test, captura o «no comprobable acá».
2. Combinaciones que ninguna ficha prueba sola: zoom 2,0 con rieles y fantasma; doble toque tras desplazar; marca de selección con zoom y cuadrícula; «Vender» armado al abrir «Menú»; presentación del jefe con rieles; tutorial completo en 16:9 y en 20:9; cambio de tamaño durante cada uno.
3. Hacer una partida entera en celular simulado en 16:9 y en 20:9, con captura de cada estado.
4. Exportar el APK **solo si** la máquina tiene todo listo (`ONBOARDING.md`), para que Lucas lo pruebe. Si no, decirlo.
5. Escribir la lista para el teléfono: cada ítem con qué hacer, qué debería pasar y una casilla. Debe cubrir pinza, un dedo, pulgares en los rieles, muesca y barra de gestos, el jefe, la marca a pleno sol, doble toque, tutorial y rendimiento con zoom. Sumar los reclamos del amigo, para que lo repruebe.
6. Dejar en la lista lo que espera a Lucas: T575, arte de T572 y T367, y B-64.

## Hecho cuando

Cada `RF` de M89 tiene su evidencia o su «no comprobable acá». Las combinaciones del paso 2 están probadas. La suite está en verde sin `SCRIPT ERROR`. La lista está en `PENDIENTES-LUCAS.md`. Se sabe si hay APK.

## Verificación

Suite completa y `git status` limpio de SVG reescritos. **No se puede probar acá:** un teléfono real: por eso la lista.

## Frenar si

Un `RF` no se cumple y arreglarlo no es un ajuste: se informa y el coordinador decide.
