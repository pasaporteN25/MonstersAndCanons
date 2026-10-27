# T453 · Sesión de partidas de Lucas: T280 + T226 + T283 (instrucciones)

**Estado (D-216, 2026-10-27):** esta sesión se ejecuta después de publicar V1, en una build identificada de esa versión. No bloquea T239. Usar un guardado nuevo en la carpeta de pruebas aislada; cualquier hallazgo se registra para una actualización.

- **Ejecutor:** **Lucas** (las partidas no las reemplazan tests ni bots) · **Prepara:** Claude (este documento, la plantilla y la build) · **Tamaño:** 2 a 3 horas, partible en dos días
- **Refs:** T280 (`03-tareas.md`), T226 y `specs/tareas/T226-prueba-bloque-2.md`, T283, RF-518 punto 4, RF-524 punto 6, RF-525, `specs/tareas/informes/T266-auditoria-dificultad.md` §7, T268.
- **Plantilla para completar:** `specs/pruebas/2026-10-sesion-humana.md` (copiarla a un archivo con la fecha de la sesión).

> **Qué cierra y qué no.** Esta sesión alimenta tres validaciones post-V1: **T280** (niveles 2 y 7), **T226 / G4** (niveles 6 a 10) y **T283** (el 9 con el Mortero). **No cierra T238 / G5** (campaña completa en PC *y* celular), que se hace aparte después de T239 con un celular real. Cada tarea sigue abierta hasta que Lucas anote resultados; **ni el bot ni los tests** reemplazan sus partidas.

## 0. Antes de jugar (lo hace Claude o Lucas, 10 minutos)

1. **Build publicada de V1.** Anotar la etiqueta y el commit de la versión que se prueba. Si se genera un ejecutable de escritorio para la sesión, partir del tag publicado y no de un `main` posterior. La exportación de Linux está configurada (`export_presets.cfg`, preset «Linux»):

   ```bash
   cd ~/Documentos/Proyectos/TDv1
   godot --headless --import
   git checkout -- assets                # --import a veces reescribe SVG
   godot --headless --path . --export-release "Linux" build/MonstersCanons.x86_64
   ```

   Comprobar con `file build/MonstersCanons.x86_64` (debe decir `ELF 64-bit`). Las plantillas de exportación son las de `ONBOARDING.md` §5. *(Alternativa sin exportar: abrir el proyecto en el editor de Godot del tag publicado.)* Anotar el resultado de `file` en la plantilla.
2. **Guardado aparte, para no tocar el tuyo y empezar «como un tester».** El juego guarda en `~/.local/share/godot/app_userdata/JuegoA/` (`save.json`). Para jugar con un guardado nuevo sin tocar el real:

   ```bash
   mkdir -p ~/pruebas-sesion/data
   XDG_DATA_HOME=~/pruebas-sesion/data ./build/MonstersCanons.x86_64
   ```

   El guardado de la sesión queda en `~/pruebas-sesion/data/godot/app_userdata/JuegoA/save.json`. **No borrar nada del guardado real.** Si se interrumpe la sesión, abrir el juego con el mismo comando y se continúa.
3. **Modo normal, no el de pruebas**, para ver las presentaciones y las estrellas como las vería un tester (el de pruebas usa otro guardado y no muestra los textos). Ver el atajo en el §4.

## 1. Orden de juego (una sola corrida cubre las tres compuertas)

Anotar **cada intento** (ganó o perdió) en la plantilla: nivel, intento, torres usadas, resultado, **vidas que quedaron**, **en qué oleada perdió vidas** y si sintió que «no había forma».

| Tramo | Qué jugar | Compuerta | Cómo |
|---|---|---|---|
| **A** | **1 → 2 → 3**, seguidos | T280 (partida 1) | «Natural»: sin plan previo, las torres que parezcan buenas. |
| **B** | **2** con torres variadas | T280 (partida 2) | Eléctrica, Múltiple, Incendiaria y alguna Ametralladora; poco Cañón y Francotirador. |
| **C** | **2** solo con Ametralladoras | T280 (partida 3) | Todas Ametralladoras, bien puestas. **Perder es lo esperado**; anotar si se entiende por qué (el Jefe y la armadura). |
| **D** | **4 y 5** | (solo para desbloquear el 6) | Jugarlos normal. No hace falta anotar vidas, aunque ayuda si querés. |
| **E** | **6 → 7 → 8**, seguidos | T280 (partida 4) y T226 | «Natural». El 8 presenta al Guardián. |
| **F** | **7** con las cuatro clásicas | T280 (partida 5) | Solo Ametralladora, Cañón, Hielo y Francotirador. Se espera ganar con poco margen o perder en la oleada 18 (control). |
| **G** | **7** mejorando temprano | T280 (partida 6) | Pocas torres, mejoradas pronto. Debería seguir ganándose. |
| **H** | **9** con el Mortero | T283 y T226 | «Natural», yendo por el Mortero (ver las 5 preguntas abajo). |
| **I** | **10** | T226 | «Natural». |
| **J** *(opcional)* | **9** demoliendo mucho | T266 §7 (partida 7) | Demoler todo antes de la oleada 10: ¿le pasa a una persona la «trampa de demoler»? |

**T226, qué mirar en los niveles 6 a 10** (una vez sin demoler ni extraer si da el tiempo, y otra con todo): ¿se entendió qué se puede demoler y qué no (1–5)? ¿compraste la demoledora, cuándo, valió la pena? ¿usaste la mina y se entendió la reserva? ¿encontraste la pieza y se entendió que estaba pendiente? ¿algún momento aburrido o injusto, dónde te trabaste? ¿algún error o algo raro?

**T283, las cinco preguntas del 9:** (1) ¿demoliste los tres escombros y llegaste a los 3 recursos? (2) **¿Compraste el Mortero y en qué oleada?** (3) ¿Cuántas vidas perdiste y en qué oleada, comparado con jugarlo sin ir por el Mortero? (4) ¿Pagar las demoliciones (270 de oro) te dejó sin defensa? (5) ¿Gastaste un recurso en el Francotirador y te quedaste sin Mortero (RF-525, riesgo 2)?

**Opcional, si querés aprovechar la sesión:** ¿se ve bien el arte nuevo de T267 en los niveles 1, 3, 5, 11, 13 y 15 y los emblemas de T437? Solo si pasás por ahí; no es parte de ninguna compuerta.

## 2. Cómo se decide después

Las cifras del bot (T279: nivel 2 `mix` ~16 vidas, `smart` ~17; nivel 7 `smart` 5–6, `mix` 12) **son una referencia, no un objetivo**. **Si una partida humana contradice al bot, manda la partida humana.**

| Qué pasa | Qué se hace (lo decide Lucas) |
|---|---|
| El 2 es más difícil que el 1 pero no un muro; el 3 no se siente más fácil que el 2 | T280 cumplido para 1–3. |
| El 2 es un muro | Registrar para una actualización y proponer la variante B del 2 (D-100). Pendiente de tu OK. |
| El 7 es un muro, o el 8 no se siente respiro | Registrar el ajuste para una actualización. |
| El 9: el Mortero no se alcanza o alcanzarlo cuesta vidas | Elegir entre **A** (bajar el costo de demoler solo en el 9), **B** (la ruina de la pieza da su recurso; enmienda RF-428), **C** (bajar el oro del Mortero; descartada de entrada, toca los niveles 10 a 15) o **D** (dejarlo así). Recién entonces se especifica como tarea nueva. |
| Un error o algo raro | Tarea nueva con número, no un arreglo al vuelo. |

Claude pasa cada problema a la tarea que corresponde (un ajuste de nivel vuelve a T223, T224 o T225 como «Ajuste») y marca las compuertas **solo** con lo que Lucas anotó.

## 3. Lo que NO prueba esta sesión

- Ni el celular ni Windows (la sesión es Linux/PC): lo cubren T238 y la ficha mobile (T454).
- Ni el rendimiento (FPS): se mide aparte, con la máquina libre.
- Ni los niveles 11 a 15 (T238, que también es post-V1).
- **Asedio 7 al 101 %** (hallazgo 2 de T444: el bot dio 5 de 5 con 6 vidas, pero T258 y P3 de M56 dicen que no cumple): si querés confirmarlo, es una partida más, aparte, y se anota en la plantilla; no bloquea las tres compuertas.

## 4. Atajo si te falta tiempo (menos fiel)

El **modo de pruebas** (Opciones → Activar modo de pruebas; `-- --pruebas` al arrancar) desbloquea todos los niveles y escribe `pruebas_stats.json` con la oleada, las vidas, el oro y las torres de cada oleada (`ONBOARDING.md` §6.1.11). Sirve para saltar directo al 6, pero **tiene otro guardado, no muestra los textos y no es la experiencia de un tester**. Si lo usás, anotalo en la plantilla («jugado en modo de pruebas»): T226 queda como resultado parcial y Lucas decide si alcanza.

## Hecho cuando

La plantilla `specs/pruebas/2026-10-sesion-humana.md` (copiada con la fecha) tiene, para cada tramo jugado, resultado, vidas, oleada de las pérdidas y la sensación; las respuestas de T226 y T283; y la decisión de Lucas (§2). Claude actualiza T280, T226 y T283 en `03-tareas.md` **con lo que Lucas anotó**, sin completar nada que no jugó.

## Resultado

*(Pendiente: lo escribe quien registre la sesión, con la fecha. Preparación hecha por Claude el 2026-10-23; build sin generar y nada jugado.)*
