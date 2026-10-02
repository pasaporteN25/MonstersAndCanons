# M27 · Integración después de revisar las muestras

## Torres

Copiar los 18 PNG de `atlases/` a `assets/sprites/towers/rendered/`, conservando los actuales de nivel 1. Orden idéntico a TowerVisual: E, SE, S, SO, O, NO, N, NE. La base fija, proyectiles, pivote de celda y balance actuales se conservan.

Agregar `turret_atlas: Texture2D` opcional en TowerLevelData; asignarlo solo en los subrecursos de niveles 2/3 de los nueve `.tres`. Tower debe elegir `stats().turret_atlas` cuando exista y recurrir al `data.turret_atlas` de nivel 1 en caso contrario. Mantener TowerVisual.frame_rect y retroceso. Los iconos entregados son mecanismos N: componer con la base del nivel correspondiente donde se necesite mostrar la evolución. La barra de construcción mantiene nivel 1.

Verificar las ocho vistas en combate, cambios de nivel, torres de 2×2, HUD y Wiki; probar fallback sin nuevo campo y que números de balance permanecen idénticos. La simple validez del PNG no prueba que su boquilla coincida perfectamente con el punto de salida actual.

## Cinco especiales

Copiar `monsters/` a `assets/sprites/enemies/rendered/` y cambiar solo `texture` y `flip_when_walking_left = false` en guardian, healer, shaman, mirror y boss. Aplicar el mismo contrato que M24: RGBA 256, cuerpo máximo 63,4%, pies 74,55%, luz fija. Conservar size_tiles y todas las habilidades/estadísticas. Son propuestas estáticas sin animaciones: no conectar a una máquina de estados de caminar. Enemy dibuja sombra, aura, barra y corona.

## Revisión

Las muestras y originales quedan en art; no cargar PNG desde directorios `.gdignore` mediante preload. Importar después de copiar y correr la suite completa. GUT revisa comportamiento; comparar además capturas a tamaño real y con quemadura, escarcha, aturdimiento y daño. Esta entrega aún requiere la revisión visual de Lucas antes de dar por aceptados los diseños.
