#!/bin/sh
# Saca todas las capturas de T469 a Capturas/ (necesita Firefox snap; ver capturar.sh).
cd "$(dirname "$0")"; C=../../Capturas
./capturar.sh frames/pc1280_inicio.html $C/T469-pc-1280x720-inicio.png 1280 720
./capturar.sh frames/pc1280_final.html $C/T469-pc-1280x720-final.png 1280 720
./capturar.sh frames/pc1920.html $C/T469-pc-1920x1080.png 1920 1080
./capturar.sh frames/pc2560.html $C/T469-pc-2560x1080-sin-desborde.png 1706 720
./capturar.sh frames/celular_inicio.html $C/T469-celular-sim-inicio.png 1688 780
./capturar.sh frames/celular_final.html $C/T469-celular-sim-final.png 1688 780
./capturar.sh hoja_catalogo.html $C/T469-insignias-catalogo.png 1250 1500
./capturar.sh hoja_numeros.html $C/T469-numeros-1-15.png 1250 1100
./capturar.sh hoja_variantes.html $C/T469-variantes-atlas.png 1500 1450
./capturar.sh hoja_zonas.html $C/T469-zonas-grises.png 1500 2300
./capturar.sh hoja_gris_candado.html $C/T469-gris-vs-candado.png 1420 1750
