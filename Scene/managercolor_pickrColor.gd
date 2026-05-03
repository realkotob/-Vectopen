extends Node
class_name GestorColor

# 1. Exportamos una variable para que arrastres el nodo ColorRect aquí
@export var nodo_color_rect: ColorRect

# 2. Señal para avisar a otros cuando el color cambie
signal color_actualizado(nuevo_color: Color)

# Variable interna para detectar cambios
var _color_anterior: Color

func _ready() -> void:
	if nodo_color_rect:
		_color_anterior = nodo_color_rect.color

func _process(delta: float) -> void:
	# Esto detecta cambios en tiempo real (incluso por animaciones o inspector)
	if nodo_color_rect:
		var color_actual = nodo_color_rect.color
		if color_actual != _color_anterior:
			_color_anterior = color_actual
			# Emitimos la señal solo si hubo un cambio
			color_actualizado.emit(color_actual)

# 3. Función GET para que otros scripts lean el color cuando quieran
func obtener_color() -> Color:
	if nodo_color_rect:
		return nodo_color_rect.color
	return Color.WHITE # Color por defecto si no hay nodo

# 4. Función SET opcional para cambiar el color desde este gestor
func establecer_color(nuevo_color: Color) -> void:
	if nodo_color_rect:
		nodo_color_rect.color = nuevo_color
		# La señal se emitirá automáticamente en el próximo _process
