# GradientEditor.gd
# Pon este script en el nodo "gradient" (Control raíz).
# El ColorRect hijo es la barra visual donde se dibuja y se arrastran los stops.

extends Control

@export var color_rect: ColorRect         # la barra visual
@export var btn_add: Button
@export var btn_remove: Button
@export var color_picker: ColorPickerButton

var stops: Array = []
var selected_index: int = -1

# ── Clase interna del stop/grabber ─────────────────────────────────────────────
class StopHandle extends ColorRect:
	signal grabbed(index: int)
	signal moved(index: int, new_pos: float)

	var index: int = 0
	var dragging: bool = false

	func _ready() -> void:
		custom_minimum_size = Vector2(12, 0)  # ancho fijo, alto = padre
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if event.pressed:
				grabbed.emit(index)

		if event is InputEventMouseMotion and dragging:
			var parent = get_parent()
			if parent == null:
				return
			var new_x: float = clamp(position.x + event.relative.x, 0.0, parent.size.x - size.x)
			position.x = new_x
			moved.emit(index, (new_x + size.x * 0.5) / parent.size.x)

	func set_selected(is_selected: bool) -> void:
		modulate = Color(1, 1, 1, 1) if is_selected else Color(0.6, 0.6, 0.6, 0.9)
		z_index   = 1 if is_selected else 0

# ── _ready ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	assert(color_rect   != null, "GradientEditor: color_rect no asignado.")
	assert(btn_add      != null, "GradientEditor: btn_add no asignado.")
	assert(btn_remove   != null, "GradientEditor: btn_remove no asignado.")
	assert(color_picker != null, "GradientEditor: color_picker no asignado.")

	btn_add.pressed.connect(func(): _add_stop())
	btn_remove.pressed.connect(_remove_selected)
	color_picker.color_changed.connect(_on_color_changed)

	# color_rect dibuja el gradiente usando _draw() propio — lo conectamos
	color_rect.draw.connect(_draw_gradient)

	_add_stop(0.0, Color.BLACK)
	_add_stop(1.0, Color.WHITE)

# ── Redimensionado ─────────────────────────────────────────────────────────────
func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_reposition_all()

# ── Añadir stop ────────────────────────────────────────────────────────────────
func _add_stop(pos: float = 0.5, color: Color = Color.GRAY) -> void:
	var handle := StopHandle.new()
	handle.color = color
	color_rect.add_child(handle)

	# Alto igual al ColorRect, ancho fijo
	handle.size = Vector2(12, color_rect.size.y)
	handle.position = Vector2(pos * color_rect.size.x - handle.size.x * 0.5, 0)

	var data := { "color": color, "pos": pos, "node": handle }
	stops.append(data)

	var idx: int = stops.size() - 1
	handle.index = idx
	handle.grabbed.connect(_select_stop)
	handle.moved.connect(_on_grabber_moved)

	_select_stop(idx)
	color_rect.queue_redraw()

# ── Seleccionar ────────────────────────────────────────────────────────────────
func _select_stop(idx: int) -> void:
	if idx < 0 or idx >= stops.size():
		return
	selected_index = idx
	color_picker.color = stops[idx].color
	for i in range(stops.size()):
		stops[i].node.set_selected(i == idx)

# ── Grabber movido ─────────────────────────────────────────────────────────────
func _on_grabber_moved(idx: int, new_pos: float) -> void:
	if idx < 0 or idx >= stops.size():
		return
	stops[idx].pos = new_pos
	color_rect.queue_redraw()

# ── Color cambiado ─────────────────────────────────────────────────────────────
func _on_color_changed(new_color: Color) -> void:
	if selected_index < 0 or selected_index >= stops.size():
		return
	stops[selected_index].color      = new_color
	stops[selected_index].node.color = new_color
	color_rect.queue_redraw()

# ── Eliminar stop ──────────────────────────────────────────────────────────────
func _remove_selected() -> void:
	if stops.size() <= 2 or selected_index < 0 or selected_index >= stops.size():
		return
	stops[selected_index].node.queue_free()
	stops.remove_at(selected_index)
	_rebuild_indices()
	_select_stop(0)
	color_rect.queue_redraw()

# ── Reconstruir índices ────────────────────────────────────────────────────────
func _rebuild_indices() -> void:
	for i in range(stops.size()):
		stops[i].node.index = i

# ── Reposicionar al redimensionar ──────────────────────────────────────────────
func _reposition_all() -> void:
	for stop in stops:
		var h: StopHandle = stop.node
		h.size = Vector2(12, color_rect.size.y)
		h.position = Vector2(stop.pos * color_rect.size.x - h.size.x * 0.5, 0)

# ── Dibujo del gradiente sobre el ColorRect ────────────────────────────────────
func _draw_gradient() -> void:
	if stops.size() < 2:
		return

	var w: float = color_rect.size.x
	var h: float = color_rect.size.y

	var sorted: Array = stops.duplicate()
	sorted.sort_custom(func(a, b): return a.pos < b.pos)

	for i in range(sorted.size() - 1):
		var s1 = sorted[i]
		var s2 = sorted[i + 1]
		var x1: float = s1.pos * w
		var x2: float = s2.pos * w

		color_rect.draw_polygon(
			PackedVector2Array([
				Vector2(x1, 0), Vector2(x2, 0),
				Vector2(x2, h), Vector2(x1, h)
			]),
			PackedColorArray([s1.color, s2.color, s2.color, s1.color])
		)

# ── Obtener Gradient nativo ────────────────────────────────────────────────────
func get_gradient() -> Gradient:
	var g := Gradient.new()
	g.remove_point(0)
	g.remove_point(0)
	var sorted: Array = stops.duplicate()
	sorted.sort_custom(func(a, b): return a.pos < b.pos)
	for s in sorted:
		g.add_point(s.pos, s.color)
	return g
