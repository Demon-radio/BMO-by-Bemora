extends ColorRect

@export var flash_speed: float = 6.0
@export var flash_colors: Array[Color] = [Color(1, 0.2, 0.2, 0.5), Color(1, 1, 0.2, 0.5)]

var is_flashing: bool = false
var time: float = 0.0

func _ready() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Make it cover entire window
	anchors_preset = Control.PRESET_FULL_RECT

func _process(delta: float) -> void :
	if is_flashing:
		time += delta * flash_speed
		# Pulse between colors
		var t = (sin(time) + 1.0) / 2.0
		color = flash_colors[0].lerp(flash_colors[1], t)
		# Also pulse alpha
		color.a = 0.3 + 0.3 * sin(time * 1.5)

func start_flash():
	is_flashing = true
	visible = true
	time = 0.0

func stop_flash():
	is_flashing = false
	visible = false
	color.a = 0.0

func flash_once(duration: float = 0.2):
	visible = true
	color = flash_colors[0]
	await get_tree().create_timer(duration).timeout
	visible = false
