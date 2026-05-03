extends Control

# Propiedades exportadas
@export var value: float = 0.0: set = _set_value
@export var step: float = 0.1  # Incremento/decremento por drag
@export var min_value: float = -1000.0  # Valor mínimo
@export var max_value: float = 1000.0  # Valor máximo
@export var line_edit: LineEdit  # Referencia al LineEdit
@export var panel: Panel  # Referencia al Panel
@export var line_edit_size: Vector2 = Vector2(60, 24)  # Tamaño del LineEdit

# Variables para drag
var is_dragging: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO

func _ready():
	# Verificar que los nodos estén asignados
	if not line_edit:
		push_error("LineEdit no asignado en el editor.")
		return
	if not panel:
		push_error("Panel no asignado en el editor.")
		return
	
	# Configurar LineEdit
	line_edit.text = "%.2f" % value  # Mostrar con 2 decimales
	line_edit.size = line_edit_size  # Usar tamaño exportado
	line_edit.custom_minimum_size = line_edit_size  # Asegurar tamaño mínimo
	line_edit.visible = true  # Asegurar visibilidad
	
	# Conectar señales
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	panel.gui_input.connect(_on_panel_gui_input)
	
	# Depuración: Verificar estado del LineEdit
	print("LineEdit visible: ", line_edit.visible)
	print("LineEdit position: ", line_edit.position)
	print("LineEdit size: ", line_edit.size)
	print("LineEdit rect_global_position: ", line_edit.global_position)
	print("Parent visible: ", get_parent().visible if get_parent() else "No parent")

# Setter para el valor exportado
func _set_value(new_value: float) -> void:
	value = clampf(new_value, min_value, max_value)
	if line_edit:
		line_edit.text = "%.2f" % value  # Mostrar con 2 decimales

# Validar entrada del LineEdit
func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float():
		value = clampf(float(new_text), min_value, max_value)
	else:
		line_edit.text = "%.2f" % value  # Revertir si no es válido

# Manejar drag en el Panel
func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_start_pos = event.position
		else:
			is_dragging = false
	elif event is InputEventMouseMotion and is_dragging:
		var delta_y = drag_start_pos.y - event.position.y
		if abs(delta_y) > 2:  # Sensibilidad del drag
			value += step * (delta_y / 10.0)  # Ajustar valor según movimiento
			drag_start_pos = event.position
