# T475 · Postes de campaña: propuesta por mapa e integración tras OK

- **Ejecutor:** Sonnet · propuesta/implementación; Codex solo arte aprobado.
- **Depende de / compuerta:** T459 aprobada; 🚦 Lucas aprueba posiciones de cada uno de los 15 mapas; T461 integrada antes de editar game.gd.
- **Tamaño:** una sesión de implementación; si el alcance real la supera, subdividir en nuevas tareas antes de mezclar cambios.
- **Refs:** RF-696, RF-697, RF-698. **Rama:** `feature/t475-postes-quince-niveles`, desde `origin/main` actualizado; un worktree, un commit `T475: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/tareas/README.md, specs/00-constitucion.md, M76 (RF-687 a RF-698) en specs/01-spec.md, D-198 a D-203, plan técnico M76 y las dos secciones finales de informes/T449-selector-campana-asedio.md.

## Objetivo y alcance

Usar las propuestas de abajo como candidatos pendientes, revalidarlas en la base vigente y preparar plano/captura por mapa. Registrar aprobación individual antes de integrar. Dibujar 1 poste en 1–10 y 2 en 11–15 en casillas permanentemente no construibles, preservando señales y grilla. Normal campaña 0–2 estrellas rebelde, 3 jugador; receta estética. Otros contextos aislados.

## Archivos previstos

datos visuales de posiciones por nivel; scenes/game/game.gd; dibujo/LevelDecor; pruebas. data/levels solo si Lucas aprueba explícitamente un ajuste visual necesario. Antes de editar, leer las reglas por carpeta correspondientes. Coordinar propietario único de archivos compartidos; nunca dos agentes sobre el mismo archivo.

## Hecho cuando

Veinte postes solo en posiciones aprobadas, 15 registros de aprobación, estrellas determinan variante sin otra progresión y comparación estructural confirma mapa jugable intacto. Mapas pendientes no se declaran terminados.

## Verificación

Tests de invariancia por cada mapa, conteo, estados/contexto/receta y GUT completo. Capturas 0/2/3 estrellas y las 15 posiciones; Lucas aprueba mapa por mapa. No se sustituye teléfono/G5 ni balance humano. Versionar cada `.uid` propio de los tests; tras import revertir solo cambios de assets no intencionales. Si import termina 139, reintentar e informar. Las capturas se guardan fuera del repo salvo las adjuntas al PR. No afirmar rendimiento sin resolución, hardware, uptime/carga y build.

## Frenar si

Falta el OK de esta spec, arte o posición que exige la ficha; hay que cambiar mapa jugable/canon/balance; otra tarea edita los mismos archivos; una prueba imprime SCRIPT ERROR aunque su resumen diga aprobada. Documentar el límite y avanzar solo con la parte independiente autorizada.

## Propuesta inicial por mapa (no aprobada)

Coordenadas `(x, y)` desde cero, origen arriba a la izquierda. Lectura de `data/levels/level_NN.json` en `45f44f3`; **no es captura del motor ni aprobación visual**. `X` es bloqueada permanente y las letras de dibujo siguientes no tienen `construible: true` (MapGrid las trata como bloqueadas). Se propone una capa visual, conservando grilla y dibujo previo; si oculta la señal/decoración, Lucas debe elegir otra posición para ese mapa. Ninguna usa agua, hielo, removible, extracción, camino, entrada/salida o casilla libre. Las posiciones de borde requieren comprobar que el poste entero entre en el encuadre.

| Nivel | Candidato(s) | Dato actual | Criterio visual propuesto | OK Lucas |
|---|---|---|---|---|
| 1 · Pradera | `(13, 5)` | `X` | Bloqueada junto al sector de la señal, sin reemplazarla | **Pendiente** |
| 2 · Desfiladero | `(1, 4)` | `s` (columna) | Señal existente: revisar coexistencia; no se retira columna | **Pendiente** |
| 3 · Encrucijada | `(15, 6)` | `,` (flores) | Decoración floral al este; conservar dibujo base | **Pendiente** |
| 4 · Espiral | `(19, 4)` | `,` (flores) | Decoración del borde este; revisar margen | **Pendiente** |
| 5 · Fortaleza | `(17, 3)` | `,` (flores) | Decoración al este, fuera de camino | **Pendiente** |
| 6 · Nido | `(18, 1)` | `p` (poste_cintas) | Conservar el poste existente, unificar solo la regla de estrellas | **Pendiente** |
| 7 · Cruce | `(17, 5)` | `X` | Bloqueada del sector este, sin tocar removibles | **Pendiente** |
| 8 · Bastión | `(0, 4)` | `s` (simbolo_ruina) | Señal del borde oeste; preservar símbolo y revisar margen | **Pendiente** |
| 9 · Taller asediado | `(0, 4)` | `s` (simbolo_ruina) | Señal del borde oeste; preservar símbolo y revisar margen | **Pendiente** |
| 10 · La mina vieja | `(22, 2)` | `X` | Bloqueada del sector este, fuera de mina/ruinas | **Pendiente** |
| 11 · Puesto seco | `(2, 1)`, `(20, 8)` | `X`; `X` | Dos bloqueadas en sectores opuestos | **Pendiente** |
| 12 · El cañadón | `(5, 0)`, `(24, 9)` | `X`; `X` | Bloqueadas al noroeste/sudeste, revisar margen superior | **Pendiente** |
| 13 · Paso alto | `(24, 0)`, `(24, 11)` | `X`; `X` | Bloqueadas este superior/inferior, revisar ambos márgenes | **Pendiente** |
| 14 · Los poblados vacíos | `(1, 1)`, `(24, 10)` | `X`; `X` | Bloqueadas opuestas, sin retirar campamentos/señales | **Pendiente** |
| 15 · La Central | `(5, 1)`, `(23, 10)` | `X`; `X` | Bloqueadas al norte/sudeste, fuera de central/abastecimiento | **Pendiente** |

Antes de implementar: preparar los 15 planos/capturas rotulados con estos candidatos y grilla, registrar fecha y referencia del OK por cada mapa y conservar ese registro en el informe de T475. Este texto permite revisar opciones, no integra posiciones ni aprueba modificaciones de arte. Si una propuesta es rechazada, mantenerla como descartada y agregar la nueva con su verificación y aprobación; no borrar el historial.
