extends Control

# Esta señal se emite cuando se activa un control en Control A.
# Se utiliza internamente y puede ser conectada externamente por otras partes del proyecto.
signal button_clicked(index)

@export var control_a: NodePath
@export var control_b: NodePath

# Variable para rastrear el uso de la señal
var _signal_used: bool = false

func _ready():
	# Marcar la señal como utilizada
	_signal_used = true

	# Inicializar controles de Control A y conectar señales
	if control_a:
		var control_a_node = get_node(control_a)
		var num_hijos_a = control_a_node.get_child_count()
		for i in range(num_hijos_a):
			var child = control_a_node.get_child(i)
			if child is Button:
				child.connect("pressed", Callable(self, "_on_control_a_activated").bind(i))
			elif child is Control:
				# Para otros tipos de Control, conectamos la señal "gui_input"
				child.connect("gui_input", Callable(self, "_on_control_a_gui_input").bind(i))
	
	# Inicializar visibilidad de hijos de Control B
	if control_b:
		var control_b_node = get_node(control_b)
		var num_hijos_b = control_b_node.get_child_count()
		for i in range(num_hijos_b):
			var child = control_b_node.get_child(i)
			child.visible = false

func _on_control_a_activated(index):
	if _signal_used:
		emit_signal("button_clicked", index)
	_update_control_b_visibility(index)

func _on_control_a_gui_input(event, index):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _signal_used:
			emit_signal("button_clicked", index)
		_update_control_b_visibility(index)

func _update_control_b_visibility(index):
	if control_b:
		var control_b_node = get_node(control_b)
		var num_hijos_b = control_b_node.get_child_count()
		if index < num_hijos_b:
			for i in range(num_hijos_b):
				var child = control_b_node.get_child(i)
				child.visible = (i == index)  # Solo hacer visible el elemento activado

# Función para uso externo que demuestra el uso de la señal
func connect_button_clicked(target: Object, method: String) -> void:
	connect("button_clicked", Callable(target, method))
