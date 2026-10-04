# M42 · Selector de enemigos de Pruebas

Capturas reales a 1920×1080: `selector.png` muestra el resaltado sin sombra exterior y `selector-final.png` el desplazamiento hasta Volador. El desplegable mide 165×320 píxeles lógicos, con fondo opaco; usa el scroll nativo. El límite de Window necesita ambas dimensiones positivas: con ancho cero el máximo de altura no se aplicaba en la captura.

Reproducir desde la raíz: `godot --path . res://art/ui-m42/capture.tscn`. Usar APPDATA aislado como en ONBOARDING para conservar el guardado del jugador; la escena usa `user://test_t188_capture.json`. No cambia assets ni balance.

Pruebas automatizadas cubren rueda mediante gui_input, extremos, eventos ajenos, invocación del elegido, altura real al abrir y selección del último ítem mediante index_pressed. La rueda sobre el selector cerrado elige anterior/siguiente; al abrir la lista por clic, la rueda desplaza su contenido.
