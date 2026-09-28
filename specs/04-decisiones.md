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
