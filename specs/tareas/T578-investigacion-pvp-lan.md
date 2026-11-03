# T578 · Investigar PvP en tiempo real por red local

- Ejecutor · Opus · esfuerzo alto
- Depende de · nada · Compuerta · ninguna · Tamaño · Mediano

## Leer

`specs/04-decisiones.md`: D-230. `specs/01-spec.md` §11 (el multijugador está excluido). `specs/00-constitucion.md`. `scenes/game/level_session.gd`, `wave_spawner.gd`, `game.gd`, `scenes/towers/tower.gd`, `scenes/enemies/enemy.gd`, `scripts/logic/rules.gd`. La documentación actual de multijugador de Godot 4.

## Objetivo

Contestar **qué tan fácil sería** una competencia en tiempo real entre dos teléfonos o PC en la misma red. **Solo investigar: no se aplica nada.**

## Alcance

**Sí:** `specs/tareas/informes/T578-investigacion-pvp-lan.md`. Una prueba mínima solo si hace falta para contestar y **fuera del repositorio**, y se describe en el informe.

**No:** código, datos o escenas del juego.

## Qué tiene que contestar

1. **Modos posibles**, de menor a mayor costo: carrera en paralelo (cada uno juega su partida y se comparan vidas u oleadas), enviar enemigos al rival, o mapa compartido. Cuál es divertido para este juego, y por qué.
2. **Arquitectura:** anfitrión contra par a par, solo enviar eventos contra simular todo y sincronizar. Sirve `MultiplayerAPI`, ENet o WebSocket. Cuánto ancho de banda y latencia hacen falta.
3. **Determinismo:** dónde dependen hoy de `delta`, `Engine.time_scale`, física, flotantes y sorteos (RF-417). Qué tan viable es sincronizar solo las acciones.
4. **Red local en la práctica:** cómo se encuentran dos dispositivos (difusión UDP, código o QR), permisos de Android (`INTERNET`, Wi-Fi, *multicast lock*), Wi-Fi con aislamiento de clientes, firewall de Windows, PC contra teléfono.
5. **Reglas de la partida:** pausa, ×2, salir del juego, desconexión y reconexión, segundo plano en Android, versiones distintas y mapas de la comunidad.
6. **Qué sirve y qué hay que cambiar del código:** archivos concretos, medido sobre `main`.
7. **Costo:** tareas por modo, con modelo y riesgo, y qué rompería de la V1 actual.
8. **Parte 2 y 3D:** si conviene hacerlo acá o guardarlo para la versión 3D.
9. **Recomendación:** hacer, posponer o descartar, y el primer paso más barato.

Citar las fuentes externas con su enlace y fecha, y separar lo verificado de lo estimado.

## Hecho cuando

El informe contesta los nueve puntos con archivos concretos y fuentes. `git diff` muestra solo el informe, la entrada del tablero y este registro.

## Verificación

No afirmar nada de rendimiento o de red sin haberlo medido: si no se probó en dos dispositivos, se dice.

## Frenar si

Contestar exige cambiar el juego. Se describe lo que haría falta, sin hacerlo.
