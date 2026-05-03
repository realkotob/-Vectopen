extends Control

@export var rich_text_label: RichTextLabel
@export var slider_line_space: Slider
@export var slider_letter_space: Slider
@export var slider_text_size: Slider

var font_variation: FontVariation
var tracking_effect = TrackingEffect.new()

func _ready() -> void:
	if not _validate_nodes(): return
	
	_setup_slider(slider_line_space, -100, 200, 0, 1)
	_setup_slider(slider_letter_space, -10, 30, 0, 0.1)
	_setup_slider(slider_text_size, 8, 120, 32, 1)
	
	for slider in [slider_line_space, slider_letter_space, slider_text_size]:
		slider.value_changed.connect(_on_slider_changed)
	
	_setup_font_and_effect()
	_apply_effects()

func _on_slider_changed(_value: float) -> void:
	_apply_effects()

func _validate_nodes() -> bool:
	var missing := []
	if not rich_text_label: missing.append("RichTextLabel")
	if not slider_line_space: missing.append("Slider Line Space")
	if not slider_letter_space: missing.append("Slider Letter Space")
	if not slider_text_size: missing.append("Slider Text Size")
	if missing.size() > 0:
		push_error("Faltan nodos: %s" % ", ".join(missing))
		return false
	return true

func _setup_slider(s: Slider, minv: float, maxv: float, def: float, step: float) -> void:
	if s.min_value == s.max_value:
		s.min_value = minv
		s.max_value = maxv
		s.value = def
		s.step = step

func _setup_font_and_effect() -> void:
	var base_font = rich_text_label.get_theme_font("normal_font")
	if not base_font:
		push_error("Asigna una fuente en Theme Overrides > Fonts > normal_font")
		return
	
	font_variation = FontVariation.new()
	font_variation.base_font = base_font as FontFile
	rich_text_label.add_theme_font_override("normal_font", font_variation)
	
	# Instalar el efecto de tracking
	rich_text_label.install_effect(tracking_effect)

func _apply_effects() -> void:
	if not font_variation: return
	
	rich_text_label.add_theme_font_size_override("normal_font_size", int(slider_text_size.value))
	rich_text_label.add_theme_constant_override("line_separation", int(slider_line_space.value))
	
	# Aplicar tracking
	tracking_effect.current_tracking = slider_letter_space.value
	
	rich_text_label.queue_redraw()

# Clase del efecto de tracking
class TrackingEffect extends RichTextEffect:
	var bbcode := "tracking"
	var current_tracking := 0.0
	
	func _process_custom_fx(char_fx: CharFXTransform) -> bool:
		char_fx.offset.x += current_tracking
		return true
