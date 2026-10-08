# T214 · Bot: estrategias sin recursos, con demolición directa, con demoledora y con extracción

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T204 y T210 (y T211 si una estrategia demuele ruinas) · **Compuerta:** ninguna · **Tamaño:** mediano

## Leer
- El RF de la "regla de oro" de M50 (ganar sin recursos, con N semillas y M victorias), escrito en T205.
- 07 §7, "Método de balance propuesto".
- `tools/balance_sim.gd` (ya con `seeds=` y `levels=` de T204).

## Objetivo
El bot sabe jugar **cinco estrategias** sobre cualquier mapa y las compara en una tabla:

| Estrategia | Qué hace |
|---|---|
| `sin_recursos` | Como `mix`: no demuele, no extrae y no construye torres con costo en recursos. **Es la que prueba la regla de oro.** |
| `demoler` | Demuele de a uno, con oro, los removibles que abren las mejores casillas. Elige por la cobertura de camino, como `smart`. |
| `demoledora` | Compra la máquina cuando quedan 4 o más removibles que valgan la pena y demuele. |
| `extraer_temprano` | Habilita la extracción en la oleada 1 o 2 y construye torres con recursos apenas puede. |
| `extraer_tarde` | Defiende primero y habilita a mitad del nivel. |

## Pasos
1. Agregar las estrategias reusando la elección de casillas existente. Se pueden combinar con `seeds=` y `levels=`.
2. Agregar columnas al informe: momento de la compra de la máquina, recursos obtenidos, recursos sobrantes, oro invertido en infraestructura y el momento de la primera torre con recursos.
3. Agregar `check_rule=1`: corre `sin_recursos` con N semillas en los mapas con recursos y **termina con código 1 si no se cumple la regla de oro**. Sirve para T236.
4. Probarlo en los mapas de ejemplo de T206 a T210.

## Hecho cuando
- La tabla de las 5 estrategias × 3 semillas en el mapa de ejemplo de T210 está en el Resultado.
- `check_rule=1` funciona y su código de salida es correcto en un caso que gana y en uno que pierde (por ejemplo, forzando `hp=` alto).
- Todos los tests en verde. Resultado, `ONBOARDING.md` (uso), commit y PR.

## Frenar si
- Una estrategia necesita decisiones de diseño (por ejemplo, qué torre con recursos prefiere el bot cuando hay varias). Elegir la más simple, anotarla y seguir: es una herramienta.
