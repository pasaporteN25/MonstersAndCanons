# T204 · Bot de balance: varias semillas e informe por mapa

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T200 (Q-07 aprobada) · **Compuerta:** ninguna · **Tamaño:** chico

## Leer
- `tools/balance_sim.gd` entero. Ya fija `rng.seed = 12345` en la línea ~66.
- `art/mechanics-m41/balance.gd` (tiene `seed=`) y `art/campaign-m45/run.py` y `README.md` (cómo se corrieron muchas simulaciones en M45).
- `specs/01-spec.md` §13, la sugerencia "Bot de balance repetible", que con Q-07 quedó aprobada.

## Objetivo
Que cualquier agente pueda correr **una sola línea** y obtener, para uno o varios mapas, el resultado de **N semillas** con una o varias estrategias:

```bash
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix level=6 seeds=5
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix levels=6-9 seeds=5 report=user://balance.json
```

## Pasos
1. Agregar `seed=N` (una semilla) y `seeds=N` (las semillas 1 a N). Tienen que fijar **todas** las fuentes de azar que afectan la partida:
   - el temblor de pantalla (RF-128), que según la sugerencia cambia los resultados;
   - el portador del avance;
   - la probabilidad de los grupos (RF-364);
   - el robo del Ladrón;
   - cualquier otro `randf` o `randi` de la partida. Buscarlos: `grep -rn "randf\|randi\|RandomNumberGenerator" scenes scripts`.
2. Agregar `levels=A-B`, que juega varios mapas seguidos.
3. Imprimir al final una **tabla resumen**: mapa, estrategia, semilla, gana o pierde, vidas, oleada de la derrota y oro sobrante. Con `report=ruta.json`, guardarla además en JSON.
4. **Repetibilidad:** la misma semilla da el mismo resultado dos veces seguidas. Si no, encontrar qué azar quedó suelto.
5. Documentar el uso en el encabezado del script y en `ONBOARDING.md`.
6. **No cambia el juego:** si para fijar una semilla hace falta tocar código de la partida, que sea solo para **inyectar** el generador, con el mismo comportamiento por defecto.

## Hecho cuando
- `mix level=7 seed=3`, corrido dos veces, da resultados idénticos.
- `mix levels=1-9 seeds=3` termina y muestra la tabla.
- Los tests completos están en verde y hay un test chico de la lectura de argumentos, si la lógica es testeable.
- Resultado en `03-tareas.md` con la tabla de la corrida 1–9 × 3 semillas: es la **línea de base** para los rebalanceos de T223 y T224. Commit y PR.

## Frenar si
- Fijar el azar exige cambiar cómo funciona algo del juego, no solo de dónde sale el número.
