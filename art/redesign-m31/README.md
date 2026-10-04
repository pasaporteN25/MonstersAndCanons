# Ciclos M31

Nueve criaturas aprobadas, cuatro direcciones por cuatro fases. Las fuentes generadas, prompts y atlas quedan conservados. `pack_walks.gd` separa figuras por alfa, usa una escala uniforme por especie y normaliza apoyo a191. `manifest.json` registra encuadre y distancia; los atlas se copian a `assets/sprites/enemies/rendered/`.

`capture.tscn` usa Enemy y los recursos de producción. Avanza la física real y fija las posiciones de exposición después de cada paso, para comparar direcciones en una captura. Los cuadros intermedios son locales; se conserva el GIF y una captura Full HD. Las auras visibles son las existentes.

Validación:889/889 GUT,8048 asserts. PNG estático sigue en Wiki; caminata se selecciona por distancia y dirección en partida. No se producen nuevos ciclos de ataque/muerte. Sombras intactas.
