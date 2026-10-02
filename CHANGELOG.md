# Novedades del juego

Lo que cambió para quien juega, de lo más nuevo a lo más viejo. El detalle técnico está en `specs/03-tareas.md` y las razones, en `specs/04-decisiones.md`.

## Monsters & Canons: logo, menú y primeros monstruos *(M24, 2026-10-02)*

- El menú principal muestra el logo **Monsters & Canons** y sus botones tienen un acabado de hierro oscuro con borde de bronce, relieve discreto y resplandor ámbar al pasar el mouse o con el teclado.
- **Normal** (diablillo rojo), **Rápido** (bestia turquesa) y **Tanque** (ogro de piedra) tienen arte nuevo en la partida, la Wiki, "Próxima oleada" y el aviso de enemigo nuevo. Vida, velocidad, recompensa, tamaño y habilidades son los mismos.
- Por ahora son imágenes fijas: miran siempre hacia el mismo lado y se mueven solo con el bamboleo de caminar (para que la luz no cambie de lado). Las evoluciones de las torres todavía no se integraron: falta arte de ocho vistas.

## Torres con volumen y tres familias visuales *(M23, 2026-10-02)*

- Cañón y mortero de hierro, bronce y madera; cinco torretas industriales; hielo y electricidad con cristal y metal claro.
- Nueve torres con ocho vistas para apuntar, tres bases según el nivel y nueve proyectiles nuevos. La luz se mantiene fija al cambiar de dirección.
- Llama renderizada, fragmentos de hielo, explosión y chispas violetas. Los efectos desaparecen al terminar y mantienen los anillos que indican el área.
- HUD y Wiki usan el nuevo arte. Los cuatro emblemas del HUD ya aceptados quedan incluidos en el repositorio.
- Conserva reglas y balance. 859 tests en verde y ejecutable Windows de pruebas verificado al arrancar. Enemigos, suelo y decoración quedan para su siguiente revisión artística.

## Modo de pruebas: oleadas finales, velocidades y atajos *(M22)*
- **Empezar en la oleada N:** en la selección de nivel del ejecutable de pruebas, una franja **"Pruebas"** deja elegir la **oleada inicial** y el **oro inicial** (automático, que es lo que se habría juntado, o a mano). Esa partida empieza sin torres y **no guarda** progreso ni récords.
- **Cinco velocidades:** x0,25 · x0,5 · x1 · x2 · x4, que se ven en el cartel "MODO PRUEBAS" y vuelven a x1 al salir. Sirve para mirar con calma el aviso de combo.
- **Atajos:** `F2` matar a todos, `F3` saltar oleada, `F4` vidas infinitas, `F6` y `F7` velocidad más lenta y más rápida (no chocan con las teclas del juego).
- **Informe:** al terminar o salir de una partida de pruebas, escribe `user://pruebas_stats.json` con la oleada, vidas, oro y torres de cada oleada (los mismos datos que el bot de balance).

## Sinergias: combinar ataques *(M20)*
- Un enemigo **ralentizado** por el Hielo recibe **+25 %** de daño del **Cañón**, el **Francotirador** y el **Mortero**; uno **quemado** por la Incendiaria recibe **+30 %** de la **Eléctrica**.
- **El combo se nota:** el número de daño del golpe sale **más grande y con "!"**, **celeste** si fue por el hielo y **naranja** si fue por el fuego, con un anillo del mismo color y un **"tin"** propio. El primer combo de cada tipo en la partida dice **"¡Combo de hielo!"** o **"¡Combo de fuego!"**. Ya no se amontona con los otros números ni se confunde con el oro, y no desaparece aunque apagues los números de daño.
- **El combo se descubre:** el **Hielo** y la **Incendiaria** dicen en su panel y en la Wiki con qué torres combinan; la barra de construcción lo nombra; y un enemigo que está listo para un combo muestra una **dianita** al lado de su barra de vida.
- Es la primera mitad; después vendrán los pares de torres vecinas.

## Torres grandes: el Mortero *(M19)*
- Primera torre de **2×2 casillas**: el **Mortero** (tecla **9**), una bomba lenta de gran daño en área y largo alcance, pensada contra blindados y jefes. Se construye en un cuadrado de cuatro casillas libres; la vista previa se centra en el mouse y se pinta verde o roja.
- Por ahora el Mortero es una torre **reservada**: solo aparece en los niveles que la habilitan (el 10, cuando exista); los demás siguen con las 8 de siempre.

## Torres apagadas: Chamán y Espejo *(M18)*
- El **Chamán** apaga la torre más cercana unos segundos con un rayo magenta; el **Espejo** devuelve los tiros de las torres cercanas y las aturde.
- Las **torres aturdidas** se ven apagadas y su panel dice cuánto falta. Todavía no aparecen en los niveles (debutan en el 10).

## Enemigos con aura: Guardián y Curandero *(M17)*
- El **Guardián** da armadura a los enemigos que lo rodean; el **Curandero** los cura. Los dos muestran un **anillo** en el suelo y ponen un escudo o una cruz sobre los que ayudan.
- Todavía no aparecen en los niveles (debutan en el 8 y el 9); se pueden ver en la Wiki y en la versión de pruebas.

## Paisajes de mapa *(M15)*
- Un nivel puede tener su **tema**: pradera, desierto, nieve, volcán, bosque, pantano o ruinas.
- Los mapas pueden pedir **lagos, hielo, lava, barro, flores y decoración** con una leyenda.
- **16 dibujos nuevos** para el mapa.

## Los enemigos, redibujados
- Los nueve enemigos tienen un dibujo nuevo, con más volumen y una silueta propia (T127).

## El editor de mapas, para todos *(M14)*
- El botón "Editor de mapas" está en el juego normal (no en el celular).

## Mapas más grandes *(M13)*
- Un mapa puede medir hasta **26×12** casillas; el juego lo achica solo para que entre.

## Wiki y bestiario *(M11, M12)*
- Nueva pantalla **Wiki** en el menú: enemigos, torres y una guía de reglas.
- Los enemigos aparecen como **"???"** hasta que los ves por primera vez en una partida.

## Mapas de la comunidad *(M10)*
- Cualquier mapa que pongas en la carpeta de mapas aparece en **Jugar → Mapas de la comunidad**, con su propio récord.

## Editor de mapas *(M9)*
- Se crean, prueban y guardan niveles con el mouse (por ahora, solo en la versión de pruebas).
- La selección de nivel acepta cualquier cantidad de niveles.

## Nivel 7 y Linux *(M8)*
- **Nivel 7 "Cruce"**, y una versión del juego para **Linux**.

## Niveles en archivos de texto *(M7)*
- Los niveles son archivos que se pueden leer y cambiar sin programar.

## Récords y modo de pruebas *(M6)*
- **Puntos**, top 5 por nivel con tres letras y **Salón de la fama** para quien gana todos los niveles.
- Un ejecutable de pruebas para probar el juego sin ensuciar el progreso.

## Contenido nuevo *(M5)*
- **4 torres nuevas** (Incendiaria, Múltiple, Ráfaga, Eléctrica) y **la Araña y el Troll** como enemigos con habilidades.
- Nivel 6 "Nido".

## Pulido *(M4)*
- Dibujos para todo, **estrellas** por nivel, avisos de enemigos peligrosos, **números de daño** y niveles 4 y 5.

## Android *(hito MA)*
- Una versión para **celular** (APK), con controles táctiles.

## Los primeros niveles *(M1 a M3)*
- El juego base: **3 niveles**, 4 torres, menú, opciones, pausa, sonido y guardado del progreso.
