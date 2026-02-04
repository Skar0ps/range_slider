@tool
extends EditorPlugin

var inspector_plugin = preload("inspector/inspector_plugin.gd").new()

func _enable_plugin() -> void:
	add_custom_type("RangeSlider","Range",preload("range_slider.gd"),null)
	add_custom_type("VRangeSlider","RangeSlider",preload("vertical/v_range_slider.gd"),preload("vertical/VRangeSlider.svg"))
	add_custom_type("HRangeSlider","RangeSlider",preload("horizontal/h_range_slider.gd"),preload("horizontal/HRangeSlider.svg"))

func _disable_plugin() -> void:
	remove_custom_type("RangeSlider")
	remove_custom_type("VRangeSlider")
	remove_custom_type("HRangeSlider")

func _enter_tree():
	add_inspector_plugin(inspector_plugin)

func _exit_tree():
	remove_inspector_plugin(inspector_plugin)
