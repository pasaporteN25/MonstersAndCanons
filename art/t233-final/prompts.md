# T233 · Instrucciones y fuentes

**Entrega PROVISIONAL, pendiente del OK artístico de Lucas.** P5 y P6 de M52 aprueban el formato y la inclusión del hito; no constituyen aprobación de estos dibujos. El despacho autorizó producir recursos provisionales para destrabar el código.

## Imagen del epílogo

Herramienta: `image_gen.imagegen` incorporada, una generación, sin imágenes de entrada. La fuente original se conserva en `sources/epilogue_generated.png`. `pack.gd` centra el recorte 16:9 y normaliza a 1920×1080 sin repintar; no modifica la fuente.

### Prompt enviado

Uso: ilustración narrativa para el epílogo de un tower defense 2D. Crear una imagen panorámica de 1920×1080, 16:9, pintada con formas facetadas legibles, materiales piedra madera hierro y bronce, luz de arriba a la izquierda y colores sobrios, coherente con un juego de edificios artesanales industriales de contorno oscuro. Cántaro al anochecer: en el primer plano y plano medio izquierdo, una colonia modesta ya asentada en un valle verde seco, casas de piedra y madera iluminadas por primera vez, una central de energía robusta de piedra con generador de hierro y bronce y ventanas cálidas, un depósito y un camino de abastecimiento que llega desde una mina en la ladera. El territorio ocupado es solo una pequeña región, el horizonte permanece vasto. Más allá de un paso de montaña, en el plano lejano derecho, varios pequeños fuegos cálidos de los Moradores forman una secuencia que se aleja hacia un horizonte azul frío; las comunidades se están retirando, sugeridas por diminutos grupos y campamentos junto a los fuegos, sin caricaturas ni villanos. Sensación ambigua de logro y costo, tranquila y sobria, sin celebración bélica. Composición legible también al reducir a celular. La franja inferior, aproximadamente el 25 por ciento del alto, debe ser oscura, tranquila y de muy bajo detalle para superponer cuatro líneas de epílogo y botones; no colocar texto en la imagen. Sin letras, títulos, logos, marcas de agua, héroes, planetas gigantes ni estética infantil. El edificio industrial debe tener chimenea corta, techo de cobre inclinado y tubería lateral, evitando parecer una torre de combate.

## Vectores nativos

Se dibujaron directamente en SVG con `build_vectors.py`, sin generación de imágenes raster para estas piezas. Referencias: `art/t249-mejoras/after/contact_220.png`, los SVG vigentes `mina.svg` y `roca_marcada.svg`, la guía completa y el canon de Cántaro.

- Central: edificio de piedra con techo de cobre, chimenea corta, generador de hierro protegido y tubería hacia la derecha. Fuente única 128×128, cuatro ventanas 64×64 en orden NO, NE, SO, SE; los cortes interiores no reciben márgenes ni contornos nuevos.
- Abastecimiento: depósito de piedra y madera, poste de línea con aisladores, vagoneta con mineral y cinta inclinada. Una vista y un estado permanente por pieza, sin bandas de demolición.
- Hito: tres piedras facetadas apiladas, sin símbolo nuevo ni marca de demolición; se distingue de la roca marcada por su silueta vertical.
- Técnica: contorno `#2b2233`, ancho 2, tres paradas por degradé, luz arriba/izquierda, transparencia y sombra suave de decoración; sin texto ni filtros.
