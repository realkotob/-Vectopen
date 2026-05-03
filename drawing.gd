extends Node2D

@onready var current_line: Line2D = $CurrentLine  # arrastra el Line2D aquí o usa get_node

var is_drawing = false
var lines: Array[Line2D] = []   # para guardar las líneas ya terminadas (si quieres varias)

func _ready():
	# Configuración inicial del Line2D
	current_line.width = 8.0
	current_line.default_color = Color.BLACK
	current_line.joint_mode = Line2D.LINE_JOINT_ROUND
	current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	current_line.end_cap_mode = Line2D.LINE_CAP_ROUND

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:                    # Click izquierdo presionado → empezar a dibujar
				is_drawing = true
				start_new_line()
			else:                                # Soltar el botón → terminar la línea actual
				if is_drawing:
					is_drawing = false
					finish_current_line()

	elif event is InputEventMouseMotion and is_drawing:
		# Mientras arrastras el mouse y el botón está presionado
		add_point_to_current_line(get_local_mouse_position())

func start_new_line():
	# Creamos una nueva línea limpia
	current_line.clear_points()
	current_line.add_point(get_local_mouse_position())

func add_point_to_current_line(pos: Vector2):
	current_line.add_point(pos)

func finish_current_line():
	# Opcional: guardar la línea terminada si quieres poder dibujar varias sin borrar
	# var new_line = current_line.duplicate()
	# add_child(new_line)
	# lines.append(new_line)
	pass
