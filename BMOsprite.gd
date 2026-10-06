extends AnimatedSprite2D

# Enhanced BMO sprite with hover and state effects
@export var hover_scale: float = 1.05
@export var hover_speed: float = 2.0

var base_scale: Vector2
var time: float = 0.0
var is_hovering: bool = false

func _ready() -> void :
	base_scale = scale
	# Add subtle idle breathing
	play("idle_blink")

func _process(delta: float) -> void :
	time += delta
	# Subtle breathing when idle
	if animation in ["idle_blink", "idle_crash", "idle_wave"] and not is_hovering:
		scale = base_scale * (1.0 + 0.02 * sin(time * hover_speed))
	# Hover effect when mouse over
	if is_hovering:
		scale = base_scale * hover_scale

func _on_mouse_entered():
	is_hovering = true
	modulate = Color(1.1, 1.1, 1.1)

func _on_mouse_exited():
	is_hovering = false
	modulate = Color(1, 1, 1)
	scale = base_scale

# Called by BMO.gd for state changes
func set_state(state: String):
	if has_animation(state):
		play(state)

func has_animation(anim_name: String) -> bool:
	return anim_name in sprite_frames.get_animation_names()
