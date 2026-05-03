extends Node

@export var color_rect: ColorRect
@export var hex_label: Label
@export var rgba_label: Label
@export var panel_container: PanelContainer
@export var texture_rect: TextureRect
@export var toggle_key: Key = KEY_I

var is_capturing: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var last_captured_color: Color = Color(0, 0, 0, 1)  # Color inicial (negro, para evitar blanco en fondos oscuros)

func _ready():
	if not color_rect or not hex_label or not rgba_label or not panel_container or not texture_rect:
		push_error("Por favor, asigna todos los nodos requeridos en el inspector")
		return
	# Inicializar visibilidad
	panel_container.visible = false
	texture_rect.visible = true
	is_capturing = false
	# Establecer color inicial
	update_ui_colors(last_captured_color)

func _input(event):
	# Detectar Ctrl + I para alternar el panel
	if event is InputEventKey and event.pressed and event.keycode == toggle_key and Input.is_key_pressed(KEY_CTRL):
		_toggle_panel()

func _process(_delta):
	if is_capturing:
		var current_mouse_pos = get_viewport().get_mouse_position()
		if current_mouse_pos != last_mouse_pos:
			last_mouse_pos = current_mouse_pos
			update_color()

func _toggle_panel():
	panel_container.visible = !panel_container.visible
	texture_rect.visible = !panel_container.visible  # TextureRect opuesto a PanelContainer
	is_capturing = panel_container.visible
	if is_capturing:
		update_color()

func update_color():
	var mouse_pos = get_viewport().get_mouse_position()
	# Capturar color de la pantalla (simulado)
	var color = get_screen_color(mouse_pos)
	last_captured_color = color
	update_ui_colors(color)

func update_ui_colors(color: Color):
	# Actualizar ColorRect
	color_rect.color = color
	# Actualizar etiquetas
	hex_label.text = color.to_html(false)
	# Convertir RGBA a escala 0-255
	rgba_label.text = "RGBA: (%d, %d, %d, %d)" % [color.r * 255, color.g * 255, color.b * 255, color.a * 255]

func get_screen_color(_pos: Vector2) -> Color:
	# Placeholder: Godot no soporta captura de color de pantalla nativamente
	# Retorna un color aleatorio como marcador
	return Color(randf(), randf(), randf(), 1.0)
