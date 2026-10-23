# T454 · `[mobile]` · Re-auditoría mobile sobre `main` y prueba en dispositivo real (ficha)

- **Ejecutor:** Fase 1 y 3, Claude (Opus para la auditoría, Sonnet para el guion y la build) · Fase 2, **Lucas con un celular** · **Tamaño:** auditoría 1 sesión; prueba en el celular 1 a 2 horas
- **Refs:** T262–T265 (informes en `specs/tareas/informes/`), T270–T276, T287–T292, M58, M60, M61, M68, T364, T369, T238, `specs/tareas/informes/T262-analisis-mobile.md` §4 y §6, `specs/tareas/informes/T289-auditoria-mobile-implementado.md`, RF-653 (el selector celular queda igual), D-097.
- **Depende de:** nada para las fases 1 y 3. T364 y T369 dependen además del rescate del PR #22 (ver `T452`) y, T369, de la reespecificación de M66 (`T448`, pendiente de Lucas).

> **Límite de entrada, dicho primero.** Hoy **no hay celular conectado** (`adb devices` no lista ningún dispositivo, 2026-10-23) y **ninguna tarea `[mobile]` se probó en un dispositivo**. El modo «Celular» en PC (Opciones → Interfaz → Celular, con el mouse haciendo de dedo) **sirve para revisar el código y la disposición, pero no valida Android**: no prueba la pinza, los milímetros reales, el rendimiento ni los gestos. **Nada de lo que sigue autoriza a decir «probado en teléfono».** Esta ficha solo deja todo listo.

## Qué vale para desktop y qué no

| Vale en PC (se puede cerrar sin celular) | No vale en PC (solo con celular real) |
|---|---|
| Medición de 60 FPS de T364 y T369 con `tools/perf_test.gd` (con la máquina **libre**) | Carrito, botones flotantes, barra de la torre elegida (D-097) |
| Protección de «Vender» (T263 §8: «en PC solo la protección») | Pinza de dos dedos, desplazamiento con el dedo, doble toque |
| Insignias en las tarjetas (T265, T270), ya en desktop | Tamaño táctil en milímetros, letra en sp, muesca, 20:9 |
| Zoom con rueda, «Ver todo» y la tecla V | Atrás de Android (RF-142), pantalla que se apaga, calentamiento |
| Cualquier hallazgo de T289 que se reproduzca con el mouse | Rendimiento y FPS reales del celular (P-14, K13, K14) |

## Fase 1 · Re-auditoría sobre `main` (agente, sin celular)

Objetivo: saber **qué de lo que T262 §4 (P-01 a P-15) y T289 (H-01 a H-25) sigue vigente** en `main`. Muchas se atacaron con M58/M60/M61; no se asume cuáles quedaron cerradas. Entregable: `specs/tareas/informes/T454-reauditoria-mobile.md`, sin tocar código.

1. **Tabla de estado.** Por cada P-xx y H-xx: qué tarea la atacó (según el tablero), si el código actual lo cumple (lectura de código y, cuando se pueda, sondeo headless como hizo T289, con guardado y `XDG_DATA_HOME` aparte), y la etiqueta **Resuelta en código · Abierta · Depende del celular**. Punto de partida, **por título de tarea y sin verificar**:

   | Problema de T262 §4 | Tarea que probablemente lo atacó | Estado a confirmar |
   |---|---|---|
   | P-01 Vender pegado a Mejorar, sin confirmar | T276 (barra de la torre, «Vender» protegido) | a confirmar |
   | P-02 Comprar al apoyar el dedo; arrastrar y pellizcar compran | T272 (gestos, fantasma con tilde y cruz) | a confirmar |
   | P-03 Sin zoom ni desplazamiento | T273 (pinza, rueda, «Ver todo») | a confirmar |
   | P-04 Botones de 3,0 a 3,2 mm | T271, T274 | a confirmar; medir en el celular |
   | P-05 El panel tapa el mapa | T275 (carrito y catálogo), T263 | a confirmar |
   | P-06 Arrastrar la lista de niveles 11 a 15 | sin tarea identificada | **abierta hasta probar** |
   | P-07 Info solo en tooltips | T265, T270 (Insignias) | a confirmar |
   | P-08 Infraestructura con botones de 2,1 a 2,4 mm | T275 / M61 | a confirmar |
   | P-09 20 % del ancho sin usar en 20:9 | **frente B** (T450, PR #51): sin decisión de Lucas | **abierta** |
   | P-10 Letra de 7 a 9,5 sp | sin tarea identificada | a confirmar |
   | P-11 Atajos de teclado visibles | sin tarea identificada | a confirmar |
   | P-12 La casilla depende del mouse | sin tarea identificada | a confirmar |
   | P-13 Pausar cancela la torre elegida | sin tarea identificada (toca RF-104) | **abierta** |
   | P-14 Tirones en las oleadas finales | T364 | **abierta** (sin medición limpia) |
   | P-15 Sin registro de prueba en celular | T238 / esta ficha | **abierta** |

2. **Desktop vs mobile.** Marcar cada fila que pueda cerrarse en PC (columna izquierda de la tabla de arriba).
3. **Riesgos de lectura y compras accidentales** a revisar con atención: toques que cuestan oro sin querer (comprar al apoyar, doble toque, tilde sobre «x2» o «Pausa»), «Vender» y «Mejorar» a poca distancia, el carrito pisando «Ver todo» o el panel, legibilidad de números de daño y oro a tamaño real, y paneles que tapan la torre elegida.
4. **Cruces con otros frentes**, sin resolverlos acá: «Ver todo» y las Opciones se revisan en T451 (PR #50); franjas del 20:9 en T450 (PR #51); la presentación de jefes (T448, PR #54) cambia lo que mide T369; la reorganización de Opciones toca `mobile_hud.gd` solo si cambia «Ver todo».

**Hecho cuando (fase 1):** el informe tiene la tabla completa con evidencia (archivo:línea o salida del sondeo), separa lo que cierra en PC de lo que no, y **no afirma nada sobre dispositivo**.

## Fase 2 · Prueba en un celular real (Lucas)

### 2.1 Build (lista para generar; **no generada ni probada todavía**)

Procedimiento de `T262` §6.1, en la máquina Linux (SDK en `~/Android/Sdk`, JDK 17 y plantillas de Godot 4.7.2 según T262 §6.1; **volver a comprobarlo antes**):

```bash
godot --headless --import && git checkout -- assets
godot --headless --path . --export-debug "Android" build/MonstersCanons.apk
~/Android/Sdk/platform-tools/adb devices                       # tiene que listar el celular
~/Android/Sdk/platform-tools/adb install -r build/MonstersCanons.apk
```

Paquete `com.monsterscanons.v1`: no pisa la APK vieja ni comparte progreso. Anotar el **commit** de la build y el **nombre del archivo**. Si `adb devices` no lista nada: depuración USB activada, cable de datos y aceptar la clave RSA en el celular.

### 2.2 Qué registrar siempre (sin esto no hay afirmación de rendimiento)

- **Celular:** marca, modelo, versión de Android, resolución, pulgadas, muesca sí/no, batería (>50 %, sin ahorro).
- **Build:** commit y archivo APK; si el modo de pruebas estaba activo (afecta FPS; apagarlo después).
- **Condiciones:** temperatura (¿caliente al empezar?), apps abiertas, brillo.
- Si además se mide en la **PC** (fase 3): resolución, procesador y GPU, **carga del sistema** (`uptime`) antes y después, y la build.

### 2.3 Guion (K1 a K14 de T262 §6.3, más lo que llegó después)

Las 14 pruebas **K1 a K14** de `T262` §6.3 (tabla completa allí: abrir el juego, arrastrar la lista, leer una tarjeta, 10 colocaciones, arrastrar y pellizcar con torre elegida, Mejorar ×3, vender sin querer, Pausa/velocidad/Menú ×5, Infraestructura, 10 torres en el 13 o el 15, atrás de Android, FPS de las 3 últimas oleadas de los niveles 1, 7 y 15, y 10 minutos seguidos). Hoy se agregan, porque T262 se escribió antes de que existieran:

| # | Prueba | Qué mirar | Anotar |
|---|---|---|---|
| K15 | **Carrito y catálogo** (T275): abrir, elegir una torre, cerrar | ¿Se entiende? ¿El carrito pisa «Ver todo» o el panel? | Sí/no; capturas |
| K16 | **Tilde y cruz del fantasma** (T272): arrastrar, soltar, tocar la tilde y la cruz | ¿Compra solo con la tilde? ¿La tilde pisa «x2» o «Pausa» con el fantasma en la primera fila? | Compras sin querer de 10 |
| K17 | **Pinza y «Ver todo»** (T273): acercar, desplazar con dos dedos, volver | ¿Aparece «Ver todo» cuando hace falta? ¿La torre elegida queda a la vista con zoom? | Sí/no |
| K18 | **«Vender» protegido** (T276): armar y desarmar, con x1 y con x2 | ¿Se desarma a los 3 s también con x2? | Segundos medidos |
| K19 | **«Empezar oleada»** (T288), niveles 1 y 7 | ¿Siempre responde al primer toque? | Fallos de 10 |
| K20 | **Insignias y tarjetas de nivel** (T265, T270) | ¿Se leen las torres sin tooltip? | Fácil / con esfuerzo / no |
| K21 | **Compras accidentales**: jugar 5 minutos sin mirar el oro y luego revisar | ¿Se gastó oro sin querer? | Cuántas veces y cómo |
| K22 | **Lectura a distancia de juego**: oro, vidas, números de daño, panel de torre | ¿Se leen sin esfuerzo? | Fácil / con esfuerzo / no |
| K23 | **Presentación de jefes**: *solo cuando exista la versión reespecificada de M66* | pausa, salteo, tiempo | Pendiente de T448 |

Reporte: el formato de `T262` §6.5, con una línea por prueba, más videos de pantalla con «Mostrar toques» activo.

**Hecho cuando (fase 2):** Lucas completó K1 a K22, con los datos del §2.2, sobre un celular real.

## Fase 3 · Medición en PC (sin celular; máquina libre)

Con `uptime` mostrando carga baja (la de T364 se midió con carga ~28 y por eso no sirve):

```bash
godot --path . -s tools/perf_test.gd                           # base
godot --path . -s tools/perf_test.gd -- mejoras                # M65: 10 mejoras seguidas
godot --path . -s tools/perf_test.gd -- mejoras sin_fx         # lo mismo con las animaciones apagadas
godot --path . -s tools/perf_test.gd -- mejoras celular        # interfaz celular en memoria
```

(`-- entrada_jefe` queda **suspendido**: mide el concepto viejo de M66.) Registrar en cada corrida: resolución, CPU y GPU, `uptime` antes y después, build y las cifras que imprime. **Un FPS sin esos datos no se da por medido.** Criterio de T364 (RF-595): 60 FPS con 60 torres, 200 enemigos y 10 mejoras seguidas, y a lo sumo 1 ms más por cuadro en modo celular. **Esto no es un resultado del celular**: en PC solo cubre la parte de T364 y T369 que vale para desktop.

## Qué NO cierra esta ficha

- **T364 y T369** siguen abiertas hasta tener el arte integrado (rescate del PR #22 / M66 reespecificada), la medición limpia en PC y el celular real.
- **T238 / G5** (campaña de 1 a 15 en PC y celular) sigue siendo de Lucas y va al final, después de T268.
- Ninguna fila se pasa a «probada en teléfono» por haber usado la interfaz celular simulada.

## Resultado

*(Pendiente. Preparación hecha por Claude el 2026-10-23: ficha escrita; sin build generada, sin celular conectado, sin mediciones y sin correr Godot.)*
