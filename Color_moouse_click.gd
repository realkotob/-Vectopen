extends Control

# Exportar referencias a los ColorRect
@export var colorrect_verde: ColorRect
@export var colorrect_amarillo: ColorRect
@export var colorrect_rojo: ColorRect

# Exportar colores
@export var color_verde: Color = Color.GREEN
@export var color_amarillo: Color = Color.YELLOW
@export var color_rojo: Color = Color.RED

# Guardar los colores originales
var color_original_verde: Color
var color_original_amarillo: Color
var color_original_rojo: Color

func _ready() -> void:
	# Guardar los colores originales
	if colorrect_verde:
		color_original_verde = colorrect_verde.color
	if colorrect_amarillo:
		color_original_amarillo = colorrect_amarillo.color
	if colorrect_rojo:
		color_original_rojo = colorrect_rojo.color

func _input(event: InputEvent) -> void:
	# Procesar tanto PRESSED como RELEASED
	if not event is InputEventMouseButton:
		return
	
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Al presionar botón izquierdo → verde
				if colorrect_verde:
					colorrect_verde.color = color_verde
				print("Click izquierdo PRESIONADO → Verde")
			else:
				# Al soltar botón izquierdo → color original
				if colorrect_verde:
					colorrect_verde.color = color_original_verde
				print("Click izquierdo LIBERADO → Color original")
		
		MOUSE_BUTTON_RIGHT:
			if event.pressed:
				# Al presionar botón derecho → rojo
				if colorrect_rojo:
					colorrect_rojo.color = color_rojo
				print("Click derecho PRESIONADO → Rojo")
			else:
				# Al soltar botón derecho → color original
				if colorrect_rojo:
					colorrect_rojo.color = color_original_rojo
				print("Click derecho LIBERADO → Color original")
		
		MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				# Al presionar botón medio → amarillo
				if colorrect_amarillo:
					colorrect_amarillo.color = color_amarillo
				print("Click central PRESIONADO → Amarillo")
			else:
				# Al soltar botón medio → color original
				if colorrect_amarillo:
					colorrect_amarillo.color = color_original_amarillo
				print("Click central LIBERADO → Color original")
