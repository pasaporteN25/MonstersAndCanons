# 04 — Registro de decisiones

> **Qué es este documento:** cada decisión importante del proyecto, con las **alternativas** que había y el **por qué** de la elección. Sirve para no volver a discutir lo mismo y para entender el proyecto dentro de unos meses.
>
> **Cómo se agrega una decisión:** copia el formato de abajo con el número siguiente. Si una decisión se cambia, **no se borra**: se marca como *Reemplazada por D-0xx* y se agrega la nueva.

---

### D-001 · Motor: Godot 4 con GDScript
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Lucas
- **Alternativas:** Web (TypeScript + Phaser), Unity (C#).
- **Por qué:** motor gratuito, liviano, excelente para 2D, con editor visual. GDScript es sencillo de aprender y está integrado en el editor.
- **Consecuencia:** Claude no puede ver el juego en ejecución; puede leer y escribir código y ejecutar tests por consola si Godot está en el `PATH`. **Las pruebas visuales las hace Lucas** y le cuenta a Claude lo que ve (una captura de pantalla ayuda mucho).

### D-002 · Vista 2D desde arriba, con formas simples
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Lucas
- **Alternativas:** pixel art desde el principio; 3D.
- **Por qué:** permite enfocarse en que el juego sea divertido. Los gráficos se cambian en M4 sin tocar la lógica, porque cada torre/enemigo se dibuja en un solo lugar (`_draw()`).

### D-003 · Camino fijo + construir en cualquier casilla libre
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Lucas
- **Alternativas:** laberinto libre (los enemigos buscan su ruta); solo puntos fijos de construcción.
- **Por qué:** es el formato más simple de programar (no hace falta búsqueda de caminos) y aun así da decisiones interesantes (dónde poner cada torre).

### D-004 · Alcance "juego mediano", construido por hitos M0–M4
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Lucas (alcance) / Claude (división en hitos)
- **Alternativas:** prototipo chico; experimento técnico.
- **Por qué:** el objetivo es un juego mediano, pero construirlo "todo a la vez" es la forma más común de no terminarlo. El hito M1 ya es un juego completo pequeño; cada hito siguiente agrega sobre algo que ya funciona.

### D-005 · Números de balance en Resources (`.tres`)
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** constantes en el código; archivos JSON.
- **Por qué:** los `.tres` se editan en el Inspector de Godot, tienen tipos (el editor no te deja poner texto donde va un número) y se pueden referenciar entre sí (un `SpawnGroup` apunta directamente a `tank.tres`). JSON obligaría a escribir código de lectura y validación.

### D-006 · Una sola escena para todas las torres (y otra para todos los enemigos)
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** una escena por tipo (`cannon.tscn`, `frost.tscn`…) con herencia.
- **Por qué:** las torres solo se diferencian en **números** (daño, área, ralentización), no en comportamiento. Una escena + datos evita duplicar código. Si en el futuro aparece una torre con un comportamiento realmente distinto, se revisa esta decisión.

### D-007 · Movimiento de enemigos con distancia + `Curve2D`, sin `PathFollow2D`
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** `PathFollow2D` por enemigo; movimiento de casilla en casilla.
- **Por qué:** ver plan §6.2. Menos nodos, sirve igual para voladores, y "cuánto le falta para llegar" (necesario para apuntar al Primero) sale directo.

### D-008 · Proyectiles que siempre impactan
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** proyectiles con física que pueden fallar; daño instantáneo sin proyectil.
- **Por qué:** fallar disparos hace el balance impredecible y frustrante. El daño instantáneo se ve pobre. El proyectil teledirigido es predecible y se ve bien.

### D-009 · Sin autoloads hasta M3
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** un autoload `GameState` global desde el principio.
- **Por qué:** los globales hacen que "reiniciar" sea propenso a errores (hay que acordarse de limpiar todo a mano). Si el estado vive en la escena, reiniciar = recargar la escena. Solo se agregan globales cuando algo **debe** sobrevivir a un cambio de escena (progreso, opciones, música).

### D-010 · Idioma: documentos en español, código en inglés
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude (se puede cambiar si Lucas prefiere)
- **Por qué:** ver constitución P9.

### D-011 · Resolución base 1280×720, casillas de 64 px, mapa de 20×9
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** mapa de 20×10 (no deja espacio para el HUD en 720 px de alto).
- **Por qué:** 16:9 es el formato de casi todos los monitores; 64 px es un tamaño cómodo para hacer clic y para dibujar; 20×9 deja 144 px para la interfaz (arriba y abajo).

### D-012 · Tests con GUT
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** GdUnit4.
- **Por qué:** GUT es simple, está en la AssetLib y se ejecuta por consola. Ambas opciones son válidas; lo importante es tener tests desde el día uno.

### D-013 · Porcentajes como enteros y valores por defecto en 0
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (durante T10)
- **Alternativas:** guardar `0.7` y `0.08` como decimales (lo que decía el plan original); valores de ejemplo como defaults en las clases de datos.
- **Por qué (porcentajes):** los decimales en la computadora no son exactos. Con `0.7`, 16 de cada 101 ventas de múltiplos de 10 se redondeaban mal (por ejemplo `170 × 0.7 = 118,999…` → 118 en vez de 119). Con enteros (`70`) la cuenta es exacta. Lo vigila `test_sell_refund_has_no_rounding_errors`.
- **Por qué (defaults en 0):** con defaults distintos de 0, un número de balance viviría en el código (contra P2), y Godot no lo escribiría en el `.tres` por ser igual al default.
- **No afecta a la spec:** 70 % y 8 % siguen siendo los mismos valores; solo cambia cómo se guardan.

### D-014 · Las torres detectan enemigos midiendo distancias, no con `Area2D`
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (durante T19)
- **Alternativas:** `Area2D` en cada torre y capas de colisión (lo que decía el plan original).
- **Por qué:** las áreas de colisión se actualizan solo en frames de física reales. Los tests simulan el tiempo más rápido que eso, así que las torres no habrían "visto" a nadie en los tests. Medir distancias es más simple, determinista y fácil de testear.
- **Costo:** unos 36.000 cálculos de distancia por segundo en el peor caso (60 torres × 200 enemigos × 3 disparos/s). Se mide en T39; si fuera lento, se optimiza midiendo primero.
- **Consecuencia:** el enemigo pasa a ser un `Node2D` y las capas de colisión quedan reservadas sin uso.

### D-015 · Balance del nivel 1 revisado con un bot
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (T25), confirmado jugando por Lucas
- **Qué:** vida base ×1,5, aumento por oleada 8 % → 40 %, daño del Cañón 12 → 20. Detalle y resultados en spec §7.1.
- **Por qué:** con los números del borrador se ganaba sin perder vidas incluso poniendo torres al azar, y el Cañón nunca convenía.
- **Herramienta:** `tools/balance_sim.gd` juega solo con tres estrategias. Se vuelve a correr cada vez que cambie el balance.

### D-016 · Adelantar el pulido visual (M1.5) antes de la profundidad (M2)
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Lucas
- **Alternativas:** seguir el orden original (M2 → M3 → M4 con el pulido al final).
- **Por qué:** con M1 terminado, Lucas confirmó que el juego es divertido, que era la condición de la constitución P4 para dejar de lado "solo formas simples". Ver el juego más vivo motiva a seguir.
- **Cómo:** se mantiene el **estilo geométrico** (sin dibujos ni sprites) porque la ambientación todavía no está decidida; así nada de este trabajo se pierde si después se cambian las formas por arte. Los efectos son solo visuales y no cambian ninguna regla.

### D-017 · "Épocas" entra al backlog como candidata a ambientación
- **Fecha:** 2026-09-28 · **Estado:** Propuesta (sin fecha) · **Propuso:** Lucas
- **Qué:** idea B-01 de la spec §13: armas y enemigos que evolucionan a través de las épocas.
- **Por qué no ahora:** cambia la ambientación, el arte y quizás la estructura de la campaña. Hacerlo antes de tener M2 (profundidad) y M3 (campaña y guardado) obligaría a rehacer trabajo. M1.5 mantiene el estilo geométrico justamente para que nada se pierda si se elige esta ambientación.
- **Próximo paso:** ninguno por ahora. Lucas decidió dejar las tres variantes (A, B, C) documentadas sin elegir ninguna; se retoma cuando él quiera.

### D-018 · Balance de los enemigos de M2 y oleadas nuevas del nivel 1
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (T38), pendiente de confirmar jugando
- **Qué:** Volador 25 → 18 de vida, Blindado 45 → 30 de vida y armadura 4 → 3, Jefe 800 → 300. Oleadas nuevas que presentan un enemigo nuevo por vez (Blindados en la 4, Voladores en la 5, Jefe en la 10). Detalle en spec §7 y §7.1.
- **Por qué:** con los valores del borrador (pensados antes del +40 % por oleada) se perdía con cualquier estrategia. Con los nuevos, el bot que mezcla torres gana con 13 vidas, el de solo Ametralladoras con 10 y el que pone torres al azar pierde en la oleada 7: la variedad de torres ahora importa.
- **Herramienta:** el bot aprendió a tener en cuenta el camino aéreo al elegir casillas para torres antiaéreas.

### D-019 · Cada nivel puede tener su propio aumento de vida por oleada
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (T43; era una pregunta abierta de la spec)
- **Qué:** `LevelData.health_scale_percent_per_wave`. Si vale 0, se usa el general de `BalanceConfig` (40 %).
- **Por qué:** con +40 % por oleada, un nivel de 20 oleadas termina con enemigos 9 veces más fuertes. Con el bot, el nivel 3 se perdía siempre en la oleada 6. Los niveles largos necesitan un aumento menor. Valores elegidos en la spec §7.4.

### D-020 · Sonidos y música sintetizados con código
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (T48)
- **Alternativas:** descargar sonidos con licencia libre (CC0); usar un editor como *jsfxr*.
- **Por qué:** descargar archivos de internet requiere revisar la licencia de cada uno y el permiso de Lucas. Sintetizarlos con `tools/make_sounds.gd` (ondas + envolventes) da sonidos "retro" que combinan con el estilo geométrico, sin dependencias externas, y se pueden regenerar cuando se quiera.
- **Cómo reemplazarlos:** poner un `.wav` con el mismo nombre en `assets/audio/`. El juego no necesita cambios.
