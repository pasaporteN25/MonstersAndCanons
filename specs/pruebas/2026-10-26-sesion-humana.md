# Sesión de partidas de Lucas · 2026-10-26

> Instrucciones: `specs/tareas/T453-sesion-humana-lucas.md`. **Esta plantilla está vacía a propósito:** nada de lo que sigue fue jugado. Compuertas: T280, T226 (G4), T283.

## Datos de preparación (la partida todavía no se jugó)

- Fecha de preparación: 2026-10-26
- Commit fuente de `origin/main`: `e5cffb84c6432caf506637d23a1d36d409b14202`
- Godot: `4.7.2.stable.official.ed1daf0bf`
- Comando de exportación: `godot --headless --path . --export-release "Linux" build/MonstersCanons.x86_64`
- Resultado de `file`: `ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 5.15.0, stripped`
- SHA-256: `3a0732165e949b4e641d5081e8558b573a2a482472151f9ccd3606e8759015c1`
- Tamaño: 267838928 bytes
- Máquina / pantalla / modo: no se abrió el juego; pendiente de Lucas
- Guardado de sesión previsto: `~/pruebas-sesion/data` (no existía al preparar esto). Ejecutar con `XDG_DATA_HOME=~/pruebas-sesion/data ./build/MonstersCanons.x86_64`; el guardado se creará ahí, separado del real.
- Modo previsto: normal, no modo de pruebas
- Partida: pendiente de Lucas

> La primera exportación falló porque todavía no existía `build/`; se creó el directorio ignorado y se repitió el comando con éxito. `godot --headless --import` terminó con código 0. Godot avisó que no encontró las herramientas Android para el Target SDK y usó 35.0.1, y que no pudo conectar con `adb`; no afectó la exportación Linux. La build está en `build/` (ignorada por Git) y no se ejecutó ni se sube al PR. Pesa 267838928 bytes, por encima de los ~75 MB de referencia de ONBOARDING §6.2; el preset incluye todos los recursos salvo `tests/*`, `tools/*`, `specs/*`, `addons/gut/*` y `art/*`, pero no excluye `Capturas/*`. No se cambió el preset como parte de esta preparación.

## Una fila por intento

| # | Nivel | Variante (natural / variadas / solo Ametralladoras / clásicas / mejorando temprano / con Mortero / demoliendo mucho) | Torres usadas | ¿Ganó? | Vidas que quedaron | Oleada(s) donde perdió vidas | ¿Sintió que «no había forma»? |
|---|---|---|---|---|---|---|---|
| 1 | | | | | | | |

## T280 · niveles 2 y 7

- ¿El 2 es más difícil que el 1 pero no un muro?
- ¿El 3 se siente más fácil que el 2?
- ¿Con torres variadas se gana el 2 sin depender del Cañón?
- ¿Solo con Ametralladoras se pierde y se entiende por qué?
- ¿El 7 es el más exigente de su trío, sin ser un muro? ¿El 8 se siente respiro?
- ¿El 7 con las cuatro clásicas se gana justo o se pierde en la 18?
- ¿El 7 mejorando temprano sigue ganándose?
- **¿Alguna partida contradice al bot?** (manda la humana) →

## T226 · niveles 6 a 10 (copiar este bloque por nivel)

### Nivel N · ¿ganaste? vidas · intentos
- ¿Se entendió qué se puede demoler y qué no? (1–5):
- ¿Compraste la demoledora? ¿Cuándo? ¿Valió la pena?:
- ¿Usaste la mina? ¿Se entendió la reserva?:
- ¿Encontraste la pieza? ¿Se entendió que estaba pendiente?:
- ¿Algún momento aburrido o injusto? ¿Dónde te trabaste?:
- ¿Algún error o algo raro?:

## T283 · el 9 con el Mortero

1. ¿Demoliste los tres escombros y llegaste a los 3 recursos?:
2. ¿Compraste el Mortero? ¿En qué oleada?:
3. Vidas perdidas y oleada, comparado con jugarlo sin ir por el Mortero:
4. ¿Pagar las demoliciones (270 de oro) te dejó sin defensa?:
5. ¿Gastaste un recurso en el Francotirador y te quedaste sin Mortero?:
- **Decisión de RF-525:** ☐ D (dejarlo así) · ☐ A (bajar el costo de demoler en el 9) · ☐ B (la ruina de la pieza da su recurso) · ☐ C (bajar el oro del Mortero)

## Opcional

- Asedio 7 al 101 %: ¿se cumple?:
- Arte de T267 (niveles 1, 3, 5, 11, 13, 15) y emblemas de T437: ¿bien?:

## Errores y cosas raras

(un renglón por cosa: nivel, qué pasó, cómo repetirlo)

## Cierre

- Lo que no se jugó:
- Lucas da por cumplidas: ☐ T280 · ☐ T226 · ☐ T283 (marcar solo lo jugado y anotado)
