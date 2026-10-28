# Prompts · T546 (muestras del final)

Generador: `codex exec -m gpt-6-luna` con su herramienta de imagen integrada (igual que T463). Encargo común (se antepone a cada variante):

COMUN: Ilustración 16:9 (sin texto, interfaz, logo ni carteles) para el final de un tower defense 2D de fantasía en el planeta fronterizo Cántaro. Es ARTE DE JUEGO ESTILIZADO, no un paisaje realista: mismo lenguaje que los recursos del mapa del juego, o sea objetos pintados «de utilería» con volumen esculpido y simplificado: rocas de basalto GORDAS con biseles y facetas grandes y musgo, árboles bajos con copas en racimos de hojas grandes agrupadas en capas, matorrales redondos, pasto oliva y caminos de tierra ocre lisos; materiales mates, detalles chicos subordinados a la silueta, sin textura fotográfica. Cámara muy ELEVADA (unos 60 grados hacia abajo, casi vista de mapa 3/4), terreno que ocupa casi toda la imagen y, como mucho, una franja finita de horizonte arriba; luz suave desde arriba a la izquierda, sombras de apoyo discretas, sin contornos negros ni resplandores. Paleta apagada y terrosa (oliva, ocre, basalto carbón, teja). Escena: una colonia pequeña de casas de piedra con techos de teja y una fábrica de vapor con chimenea sobre una loma a la izquierda, caminos de tierra, algunas ventanas con luz. Composición: el tercio inferior (30 %) queda calmo, liso, de bajo contraste y sin detalle (ahí el juego superpone una frase); el interés va arriba y a los lados; nada importante en los bordes superior e inferior.

## Variantes (texto completo en `variantes.sh`; `run.sh` arma el pedido a `codex exec`)

- **Luminosa:** atardecer limpio y cálido, colonia con ventanas y faroles encendidos, y a lo lejos fuegos de campamento y tiendas de los Moradores alejándose por un camino; «nada oscuro ni amenazante».
- **Oscura:** la misma escena base y, en el horizonte lejano, un frente de tormenta ambiguo (nubes y lluvia en gris pizarra, verdoso y violeta desaturado), sin forma reconocible; luz cálida en la colonia.

## Rondas (honesto)

| Ronda | Qué se pidió | Resultado |
|---|---|---|
| 1 (`descartada_a1`, `descartada_b1`) | Encargo común con «misma familia que el mapa» pero sin pedir estilización ni cámara muy elevada | **Descartadas:** paisaje cinematográfico casi realista, horizonte alto, sol y relieve fotográficos. No es la familia del mapa. |
| 2 (`a2`, `descartada_b2`) | Encargo reformulado (arte de juego estilizado, rocas gordas facetadas, copas en racimos de hojas grandes, cámara ~60° hacia abajo) | `a2` pasa la compuerta (**muestra luminosa 01**). `b2` **descartada** al ampliar: en el horizonte hay un campamento ardiendo con una columna de humo (una amenaza reconocible; Lucas pidió ambigua) |
| 3 (`a3`, `descartada_b3`) | Composición alternativa (colonia a la derecha) | `a3` pasa, algo más pictórica y menos «de utilería» que `a2` (**muestra luminosa 02**). `b3` **descartada**: aldea ardiendo con humo en el horizonte |
| 4 (`b4`, `b5`) | Oscura con «PROHIBIDO: fuegos, humo, aldeas ardiendo, rayos, siluetas…» | `b4` pasa (**muestra oscura 01**). `b5` queda en `sources/` pero **no se presenta**: la tormenta casi no se ve (franja finita arriba a la derecha) |
| 5 (`b6`, `b7`) | Igual, con la tormenta pedida más visible | `b6` pasa (**muestra oscura 02**). `b7` **no se presenta**: tormenta tímida, el 90 % es pasto |

Nota: la orden se repitió «sin reescalar»; el generador entrega 1672×941. Las muestras `muestra_*.png` son esa salida escalada con Lanczos a 1920×1080 (ampliación del 15 %, sin retoque); las fuentes crudas están en `sources/`.
