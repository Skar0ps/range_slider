## This script is the custom EditorProperty for Vector2 properties with a range hint.
## It instances and manages the RangeSlider control in the inspector.
@tool
extends EditorProperty

var vbox := VBoxContainer.new()

var min_max_hbox := HBoxContainer.new()

## The RangeSlider instance.
var range_slider := HRangeSlider.new() 

## The SpinBox with a slider for the minimum value (x)
var min_spin_slider := EditorSpinSlider.new()

## The SpinBox with a slider for the maximum value (y)
var max_spin_slider := EditorSpinSlider.new()

var margin_container := MarginContainer.new()


# Guard against internal updates when syncing state.
var _is_updating := false
# Whether to treat the values as radians and display them as degrees.
var _radians_as_degrees := false


# Variables to store setup data from the inspector plugin.

var _exp_edit: bool
var _allow_greater: bool
var _allow_lesser: bool
var _suffix: String
var _min_value: float
var _max_value: float
var _step: float



## Sets up the property editor with the given parameters from the inspector plugin.
func setup(p_min: float, p_max: float, p_step: float, p_exp: bool, p_allow_greater: bool, p_allow_lesser: bool, p_hide_slider: bool, p_suffix: String, p_radians_as_degrees: bool) -> void:
	if p_radians_as_degrees:
		p_min = rad_to_deg(p_min)
		p_max = rad_to_deg(p_max)
		p_step = rad_to_deg(p_step)

	range_slider.min_value = p_min
	range_slider.max_value = p_max
	range_slider.step = p_step
	range_slider.exp_edit = p_exp
	
	min_spin_slider.min_value = p_min
	min_spin_slider.max_value = p_max
	min_spin_slider.step = p_step
	min_spin_slider.exp_edit = p_exp
	min_spin_slider.allow_greater = p_allow_greater
	min_spin_slider.allow_lesser = p_allow_lesser
	min_spin_slider.suffix = p_suffix if p_suffix else "°" if p_radians_as_degrees else ""

	max_spin_slider.min_value = p_min
	max_spin_slider.max_value = p_max
	max_spin_slider.step = p_step
	max_spin_slider.exp_edit = p_exp
	max_spin_slider.allow_greater = p_allow_greater
	max_spin_slider.allow_lesser = p_allow_lesser
	max_spin_slider.suffix = p_suffix if p_suffix else "°" if p_radians_as_degrees else ""
	
	_step = p_step
	_min_value = p_min
	_max_value = p_max
	_exp_edit = p_exp
	_allow_greater = p_allow_greater
	_allow_lesser = p_allow_lesser
	_suffix = p_suffix
	_radians_as_degrees = p_radians_as_degrees

func _ready() -> void:
	_build_ui_tree()
	_configure_layout()
	_setup_spin_sliders()
	_connect_signals_and_focus()


func _build_ui_tree() -> void:
	add_child(vbox)
	set_bottom_editor(vbox)

	vbox.add_child(range_slider)
	vbox.add_child(margin_container)

	margin_container.add_child(min_max_hbox)
	min_max_hbox.add_child(min_spin_slider)
	min_max_hbox.add_child(max_spin_slider)


func _configure_layout() -> void:
	vbox.add_theme_constant_override("separation", 4)
	min_max_hbox.add_theme_constant_override("separation", 8)

	var start_handle_width: float = range_slider._get_start_handle_extent()
	var end_handle_width: float = range_slider._get_end_handle_extent()
	margin_container.add_theme_constant_override("margin_left", start_handle_width)
	margin_container.add_theme_constant_override("margin_right", end_handle_width)

	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	range_slider.size_flags_horizontal = SIZE_EXPAND_FILL
	min_max_hbox.size_flags_horizontal = SIZE_EXPAND_FILL
	min_spin_slider.size_flags_horizontal = SIZE_EXPAND_FILL
	max_spin_slider.size_flags_horizontal = SIZE_EXPAND_FILL


func _setup_spin_sliders() -> void:
	var editor_theme: Theme = EditorInterface.get_editor_theme()
	var property_x_color: Color = editor_theme.get_color("property_color_x", "Editor")
	var property_y_color: Color = editor_theme.get_color("property_color_y", "Editor")

	min_spin_slider.label = "min"
	min_spin_slider.add_theme_color_override("label_color", property_x_color)

	max_spin_slider.label = "max"
	max_spin_slider.add_theme_color_override("label_color", property_y_color)

	var spin_slider_stylebox: StyleBoxFlat = get_theme_stylebox("normal", "LineEdit").duplicate()
	spin_slider_stylebox.content_margin_left = 0
	spin_slider_stylebox.content_margin_right = 0

	var spin_slider_theme := Theme.new()
	spin_slider_theme.set_stylebox("normal", "LineEdit", spin_slider_stylebox)

	min_spin_slider.theme = spin_slider_theme
	max_spin_slider.theme = spin_slider_theme

func _connect_signals_and_focus() -> void:
	range_slider.range_changed.connect(_on_range_changed)
	min_spin_slider.value_changed.connect(_on_min_spinbox_value_changed)
	max_spin_slider.value_changed.connect(_on_max_spinbox_value_changed)

	add_focusable(range_slider)
	add_focusable(min_spin_slider)
	add_focusable(max_spin_slider)

	range_slider.focus_neighbor_bottom = min_spin_slider.get_path()
	min_spin_slider.focus_neighbor_top = range_slider.get_path()
	min_spin_slider.focus_neighbor_bottom = max_spin_slider.get_path()
	min_spin_slider.focus_neighbor_left = range_slider.get_path()
	min_spin_slider.focus_neighbor_right = max_spin_slider.get_path()
	max_spin_slider.focus_neighbor_left = min_spin_slider.get_path()
	max_spin_slider.focus_neighbor_right = range_slider.get_path()
	max_spin_slider.focus_neighbor_top = min_spin_slider.get_path()

func _update_property() -> void:
	_is_updating = true
	
	var current_value: Vector2 = get_edited_object().get(get_edited_property())
	
	# The actual property clamping and update is deferred by the debounce timer.
	var value_for_slider: Vector2 = current_value
	if _radians_as_degrees:
		value_for_slider = Vector2(rad_to_deg(current_value.x), rad_to_deg(current_value.y))
	
	range_slider.value_range = value_for_slider
	
	min_spin_slider.value = value_for_slider.x
	max_spin_slider.value = value_for_slider.y
	
	_is_updating = false

func _set_read_only(read_only: bool) -> void:
	min_spin_slider.read_only = read_only
	max_spin_slider.read_only = read_only
	range_slider.editable = not read_only

## Called when the range of the slider is changed by the user.
func _on_range_changed(new_range: Vector2) -> void:
	if _is_updating:
		return
	
	_is_updating = true
	
	var value_to_emit: Vector2 = new_range
	if _radians_as_degrees:
		value_to_emit = Vector2(deg_to_rad(new_range.x), deg_to_rad(new_range.y))
	
	min_spin_slider.value = new_range.x
	max_spin_slider.value = new_range.y

	emit_changed(get_edited_property(), value_to_emit)
	
	_is_updating = false

func _on_min_spinbox_value_changed(new_value: float) -> void:
	if _is_updating:
		return

	_is_updating = true
	
	var current_max: float = max_spin_slider.value
	var new_max: float = maxf(new_value, current_max)
	var target_range: Vector2 = Vector2(new_value, new_max)
	
	range_slider.value_range = target_range
	
	min_spin_slider.value = target_range.x
	max_spin_slider.value = target_range.y

	var value_to_emit: Vector2 = target_range
	if _radians_as_degrees:
		value_to_emit = Vector2(deg_to_rad(value_to_emit.x), deg_to_rad(value_to_emit.y))
	emit_changed(get_edited_property(), value_to_emit)
	
	_is_updating = false

func _on_max_spinbox_value_changed(new_value: float) -> void:
	if _is_updating:
		return
	
	_is_updating = true
	
	var current_min: float = min_spin_slider.value
	var new_min: float = minf(new_value, current_min)
	var target_range: Vector2 = Vector2(new_min, new_value)
	
	range_slider.value_range = target_range
	
	min_spin_slider.value = target_range.x
	max_spin_slider.value = target_range.y

	var value_to_emit: Vector2 = target_range
	if _radians_as_degrees:
		value_to_emit = Vector2(deg_to_rad(value_to_emit.x), deg_to_rad(value_to_emit.y))
	emit_changed(get_edited_property(), value_to_emit)
	
	_is_updating = false
