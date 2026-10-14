# T221 · 🎨 Íconos: recurso, piezas de colección y demoledora

- **Ejecutor:** **Codex**
- **Depende de:** T205 (y T215 para el nombre y aspecto de la colección de la Disruptora) · **Compuerta:** 🎨 concepto aprobado · **Tamaño:** chico

## Leer
- `specs/tareas/README.md` §6 y la guía §M37 (el avance plateado: disco de metal con silueta de nave).
- Los íconos actuales del HUD: `assets/sprites/ui/stat_*.svg` y el ícono del avance (`grep -rn "avance\|advance" scenes/game/hud.gd` para encontrar su archivo).
- La sección M50 del plan (dónde se muestra cada ícono).

## Entregables

Nombres propuestos en la sección M50 del plan técnico: `assets/sprites/ui/stat_resources.svg`, `coleccion_disruptor.svg` y `demoledora.svg`. Cada colección de `progression.json` tiene su `icono` (RF-425, RF-431).

| Ícono | Uso | Formato |
|---|---|---|
| Recurso genérico | Contador del HUD, costos de la barra y Wiki | Mismo formato y tamaño que `stat_gold.svg`. **No** es oro ni madera ni piedra: es "material" genérico (propuesta: un lingote o paquete de hierro y bronce con una correa). |
| Pieza de la Disruptora | Barra de la colección, panel de la ruina y Wiki | Variante del avance plateado (Q-39), con una **silueta de bobina con anillos** en lugar de la nave. |
| Demoledora | Botón o panel "Infraestructura" | Una máquina compacta (martillo pilón o ariete con ruedas) en hierro y bronce. Q-08 decidió que **no** se pone en el mapa: solo ícono, salvo que el plan pida también una animación de trabajo. |
| (Opcional) Máquina trabajando | Sobre el removible durante el trabajo con máquina | 64 × 64, 2 o 4 cuadros, si el plan M50 lo pide. |

## Pasos
Concepto, OK de Lucas, producción, integración de rutas en el HUD (o anotarla), captura del HUD con el contador y la barra, y tests en verde. Commit `T221: …` y PR.
