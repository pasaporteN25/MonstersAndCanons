# 00 — Constitución del proyecto

> **Qué es este documento:** las reglas que valen para **todo** el proyecto y que **no se negocian** tarea por tarea. Son pocas a propósito. Cada una explica su *por qué*, porque una regla sin razón se termina ignorando.
>
> **Cómo se cambia:** solo si hay una buena razón, y dejándolo anotado en [`04-decisiones.md`](04-decisiones.md).

---

## P1. El juego siempre se puede ejecutar

Al terminar **cada** tarea, el juego abre y se puede jugar (aunque falten cosas). Nunca se deja el proyecto "a medio romper" de un día para otro.

**Por qué:** si el juego está roto durante días, cuando algo falla no sabes cuál de los 20 cambios lo causó. Si funciona después de cada paso, el error siempre está en el último paso.

## P2. Los números van en archivos de datos, no en el código

Costos, daño, vida, velocidad, oleadas, alcance… todo número de **balance** vive en archivos `.tres` (Resources de Godot) dentro de `data/`. El código **lee** esos números; nunca los escribe "a mano" (*hardcodeados*).

**Por qué:** balancear un tower defense significa cambiar números cientos de veces. Si están en el código, cada ajuste es tocar código y arriesgarte a romper algo. Si están en datos, se cambian desde el editor de Godot en segundos, sin tocar la lógica.

```gdscript
# MAL: el número está escondido en el código
func shoot() -> void:
    target.take_damage(5)

# BIEN: el número viene de los datos de la torre
func shoot() -> void:
    target.take_damage(data.damage)
```

## P3. La spec manda

Si hay duda sobre cómo debe comportarse el juego, la respuesta está en [`01-spec.md`](01-spec.md). Si la respuesta no está, **primero se agrega a la spec** y después se programa.

**Por qué:** evita que el juego "se invente" sobre la marcha y que dos partes del código asuman reglas distintas.

## P4. Simple primero

- Se programa lo que pide la tarea actual, **no** lo que "quizás haga falta después".
- Gráficos con formas simples (círculos, cuadrados, colores) hasta que la mecánica sea divertida.
- No se optimiza nada sin haber medido primero que es lento.

**Por qué:** la mayoría de los juegos amateur se abandonan por exceso de ambición, no por falta de ideas. Lo simple se termina.

## P5. GDScript con tipos estáticos

Todas las variables, parámetros y retornos llevan tipo.

```gdscript
# MAL
var speed = 1.5
func take_damage(amount):

# BIEN
var speed: float = 1.5
func take_damage(amount: int) -> void:
```

**Por qué:** Godot detecta muchos errores **antes** de ejecutar el juego, el autocompletado funciona mejor y el código corre más rápido.

## P6. Señales hacia arriba, llamadas hacia abajo

- Un nodo **padre** puede llamar funciones de sus **hijos** directamente (`enemy.take_damage(10)`).
- Un nodo **hijo** **nunca** busca a su padre ni a sus "hermanos". Si tiene algo que avisar, **emite una señal** (`died.emit()`), y quien le interese la escucha.

**Por qué:** así cada escena funciona sola. Puedes abrir `enemy.tscn` y probarla aislada, sin que se rompa porque "no encuentra el nivel". Es la regla que más problemas evita en Godot.

## P7. Rendimiento mínimo

El juego mantiene **60 FPS** con **200 enemigos** y **60 torres** en pantalla, en un PC normal.

**Por qué:** es un número concreto contra el cual comprobar. Sin un número, "va bien" o "va lento" es pura opinión.

## P8. Tareas pequeñas y verificables

Cada tarea de [`03-tareas.md`](03-tareas.md):
- se puede terminar en **una sesión de trabajo** (unas pocas horas como máximo);
- tiene un **criterio de aceptación**: una frase que dice exactamente cómo comprobar que está hecha.

**Por qué:** una tarea que no sabes cuándo está terminada, nunca se termina.

## P9. Idioma

- **Documentos y comentarios:** en español.
- **Código** (nombres de variables, funciones, archivos, escenas): en **inglés**.

**Por qué:** la API de Godot está en inglés (`position`, `queue_free()`, `add_child()`); mezclar idiomas en el código lo hace más difícil de leer. Además, casi toda la ayuda que encontrarás en internet usa nombres en inglés.

## P10. La lógica importante se prueba automáticamente

Los cálculos puros (daño con armadura, reembolso al vender, oro de oleada, guardado) se escriben como funciones que **no dependen de la escena** y se prueban con **GUT** (herramienta de tests para Godot), en la carpeta `tests/`.

**Por qué:** un error en una fórmula de daño no se nota jugando cinco minutos, pero arruina el balance. Un test lo detecta al instante y para siempre.
