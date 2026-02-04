@tool
extends Control

@export_range(0.0,100.0,0.1) var float_range : float

# Basic range slider
@export_custom(PROPERTY_HINT_RANGE, "0.0,10.0,0.5") var basic_range: Vector2

# Range slider with different min, max, and step
@export_custom(PROPERTY_HINT_RANGE, "-100.0,100.0,1.0,suffix:px") var pixel_range: Vector2

# Range slider with or_greater and or_less
@export_custom(PROPERTY_HINT_RANGE, "0,10,1,or_greater,or_less") var open_range: Vector2

# Range slider with exponential editing
@export_custom(PROPERTY_HINT_RANGE, "0.01,100.0,0.01,exp") var exponential_range: Vector2

# Range slider for radians displayed as degrees
@export_custom(PROPERTY_HINT_RANGE, "-3.14159,3.14159,0.196349375,radians_as_degrees") var angle_range: Vector2 :
	set(value):
		angle_range = value
		print(angle_range)

# Range slider with degrees suffix
@export_custom(PROPERTY_HINT_RANGE, "0,360,1,degrees") var degrees_range: Vector2

# This one should not use the custom slider
@export_custom(PROPERTY_HINT_RANGE, "0,100,1,hide_slider") var hidden_slider_range: Vector2

# Angle example: A range from -180 to 180 degrees.
# The property is stored in radians but displayed in degrees.
@export_custom(PROPERTY_HINT_RANGE, "-3.14159,3.14159,0.1,radians_as_degrees") var angle_shown_range: Vector2

# Basic range slider
@export_custom(PROPERTY_HINT_RANGE, "0.0,10.0,0.5",PROPERTY_USAGE_READ_ONLY + PROPERTY_USAGE_EDITOR) var read_only_range: Vector2 = Vector2(4.0,7.0)
