# T235 · Asedio con 15 mapas y pulido de modos

> **Retirada como ejecución independiente y absorbida por T473 (T459/RF-694).** Los 15 mapas fueron implementados por T258. Este archivo conserva el historial; solapas/récords siguen pendientes y su ficha vigente es `T473-modos-solapas-records.md`, después del OK de Lucas a T459.

- **Ejecutor:** Sonnet 5.5 · esfuerzo **bajo**. La parte 1 es *apta Qwen* (solo datos).
- **Depende de:** T234 · **Compuerta:** ninguna · **Tamaño:** chico

## Leer
RF-388 a RF-392, `data/modos/asedio/modo.json` y el Resultado de T197 (sus límites conocidos).

## Pasos
1. **(Apta Qwen)** Agregar `level_10` a `level_15` a `"mapas"` de `data/modos/asedio/modo.json`.
2. Bot `mix modo=asedio levels=10-15 seeds=3`. Informar cuáles se ganan. **No ajustar** el 115 % (RF-391) sin consultar.
3. Los dos límites que dejó T197:
   - con más de dos modos propios, las solapas no entran en la fila (hacerlas desplazables o un selector);
   - los récords de los modos no aparecen en la pantalla de Récords.
   Si alguno necesita un RF nuevo, es 📜.
4. **Verificar** con un test que las piezas de colección no se generan en Asedio (Q-31) y que **los textos de nivel no se muestran en Asedio** aunque el mapa sea de la campaña (RF-468: ni el cartel de entrada ni el texto de victoria; el lugar de la tarjeta tampoco).

## Hecho cuando
Asedio tiene 15 mapas, las solapas y los récords están resueltos, y todos los tests en verde. Resultado, commit y PR.
