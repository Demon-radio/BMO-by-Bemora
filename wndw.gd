extends Window

@onready var cam: Camera2D = $Camera2D

var last_pos = Vector2i.ZERO
var velocity = Vector2i.ZERO
var snap_threshold: int = 20
var is_dragging: bool = false

func _ready() -> void :
	cam.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	close_requested.connect(queue_free)
	# Restore last position if saved
	var saved_pos = ConfigFile.new()
	if saved_pos.load("user://bmo_window.cfg") == OK:
		var x = saved_pos.get_value("window", "pos_x", position.x)
		var y = saved_pos.get_value("window", "pos_y", position.y)
		position = Vector2i(x, y)
	# Enable per-pixel transparency for smooth dragging
	transparent_bg = true

func get_camera_pos() -> Vector2i:
	return position + velocity

func _process(delta: float) -> void :
	velocity = position - last_pos
	last_pos = position
	cam.position = get_camera_pos()
	# Snap to screen edges for better UX
	if not is_dragging:
		var screen_rect = DisplayServer.screen_get_usable_rect()
		if abs(position.x) < snap_threshold:
			position.x = 0
		elif abs((position.x + size.x) - screen_rect.size.x) < snap_threshold:
			position.x = screen_rect.size.x - size.x
		if abs(position.y) < snap_threshold:
			position.y = 0
		elif abs((position.y + size.y) - screen_rect.size.y) < snap_threshold:
			position.y = screen_rect.size.y - size.y

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Save position on close
		var cfg = ConfigFile.new()
		cfg.set_value("window", "pos_x", position.x)
		cfg.set_value("window", "pos_y", position.y)
		cfg.save("user://bmo_window.cfg")
		queue_free()

func set_dragging(drag: bool):
	is_dragging = drag
