extends Node

## Script para alternar la visibilidad de un nodo objetivo cuando se emite una señal desde un nodo de activación.
class_name ToggleVisibility

## Nodo objetivo cuya visibilidad será alternada.
@export var target_node_path: NodePath:
	set(value):
		target_node_path = value
		_update_target_node()
## Nodo que activa la alternancia (ej. Button, TextureButton).
@export var button_toggle_path: NodePath:
	set(value):
		button_toggle_path = value
		_update_button_node()
## Nombre de la señal que activa la alternancia (por defecto 'pressed').
@export var toggle_signal: StringName = &"pressed"

# Referencias a los nodos
var _target_node: Node = null
var _button_toggle: Node = null

# Estado de inicialización
var _is_initialized: bool = false

## Se ejecuta cuando el nodo entra en el árbol de escena.
func _ready() -> void:
	# Actualizar referencias a nodos
	_update_target_node()
	_update_button_node()
	# Configurar la conexión de la señal
	_setup_signal_connection()

## Actualiza la referencia al nodo objetivo.
func _update_target_node() -> void:
	if not is_inside_tree():
		return
	_target_node = get_node_or_null(target_node_path)
	if not _target_node:
		push_error("Error: 'target_node_path' (%s) no apunta a un nodo válido." % target_node_path)
		return
	if not ("visible" in _target_node):
		push_error("Error: El nodo objetivo (%s) no tiene la propiedad 'visible'." % _target_node.name)
		_target_node = null

## Actualiza la referencia al nodo de activación.
func _update_button_node() -> void:
	if not is_inside_tree():
		return
	_button_toggle = get_node_or_null(button_toggle_path)
	if not _button_toggle:
		push_error("Error: 'button_toggle_path' (%s) no apunta a un nodo válido." % button_toggle_path)
		return
	if toggle_signal.is_empty():
		push_error("Error: 'toggle_signal' no está especificado.")
		_button_toggle = null

## Configura la conexión de la señal de alternancia.
func _setup_signal_connection() -> void:
	if _is_initialized or not _button_toggle or not _target_node:
		return
	
	if not _button_toggle.has_signal(toggle_signal):
		push_error("Error: El nodo de alternancia (%s) no tiene la señal '%s'." % [_button_toggle.name, toggle_signal])
		return
	
	var callable = Callable(self, "_on_toggle_activated")
	if not _button_toggle.is_connected(toggle_signal, callable):
		var error = _button_toggle.connect(toggle_signal, callable)
		if error != OK:
			push_error("Error: No se pudo conectar la señal '%s' del nodo '%s'. Código de error: %d" % [toggle_signal, _button_toggle.name, error])
			return
	
	_is_initialized = true

## Maneja la activación de la señal de alternancia.
func _on_toggle_activated() -> void:
	if not _target_node or not ("visible" in _target_node):
		return
	_target_node.visible = not _target_node.visible

## Limpia las conexiones de señales al salir del árbol de escena.
func _exit_tree() -> void:
	if _button_toggle and _button_toggle.has_signal(toggle_signal):
		var callable = Callable(self, "_on_toggle_activated")
		if _button_toggle.is_connected(toggle_signal, callable):
			_button_toggle.disconnect(toggle_signal, callable)
	_is_initialized = false

## Reacciona a cambios en las propiedades exportadas.
func _notification(what: int) -> void:
	if what == NOTIFICATION_PATH_RENAMED:
		_update_target_node()
		_update_button_node()
		_setup_signal_connection()
