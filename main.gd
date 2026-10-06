extends Node2D

@onready var mainWindow: Window = get_window()
@onready var alarm: ColorRect = $ColorRect
@onready var timer: Timer = $Timer
@onready var anim: AnimationPlayer = $BMO / AnimationPlayer
@onready var char_sprite: AnimatedSprite2D = $BMO / AnimatedSprite2D
@onready var emit: CPUParticles2D = $CPUParticles2D
@onready var menu: PopupMenu = $PopupMenu
@onready var audio: AudioStreamPlayer = $BMO / AudioStreamPlayer

var song = ""
var song_queue: Array = []
var last_song: String = ""
# LOUD songs ("big" sound): +6 dB boost on the sing player
const SONG_VOLUME_DB: float = 6.0
var color = [Color.hex(12285814), Color.hex(5177344)]
var is_walking: bool = false
var follow: bool = false
var picked: bool = false
var singing: bool = false
var alarm_bool: bool = false
var walk_direction: int = 1
var up_direction: int = 1
var last_mp: Vector2
var prev: Vector2 = Vector2.ZERO
var player_size: Vector2i = Vector2i(375, 425)
var menu_size: Vector2 = Vector2(200, 100)
var taskbar_pos: int = (DisplayServer.screen_get_usable_rect().size.y - player_size.y)
var screen_width: int = DisplayServer.screen_get_size().x - 5
var mouse_offset: Vector2 = Vector2.ZERO
var songs: Array = [
	# KEEPERS (old): "BMO why so pregnant" + cowboy/horse
	"res://assets/Audio/song_egg.mp3",
	"res://assets/Audio/song_horse.mp3",
	# Come Along With Me (restored, biggest original ~1.25 MB)
	"res://assets/Audio/song_comealong.mp3",
	# MOST POPULAR BMO songs (drop your own licensed copies here):
	# Bacon Pancakes + Oh BMO — see assets/Audio/README_SONGS.md
	"res://assets/Audio/song_pop_bacon_pancakes.wav",
	"res://assets/Audio/song_pop_oh_bmo.wav",
	# 4 TALL LARGE songs (loud ~1.3 MB placeholders, replace with licensed audio)
	"res://assets/Audio/song_big_01_fresh_potatoes.wav",
	"res://assets/Audio/song_big_02_island_anthem.wav",
	"res://assets/Audio/song_big_03_adventure_theme.wav",
	"res://assets/Audio/song_big_04_bmo_party.wav",
]
const WALK_SPEED: int = 200

enum Menu_IDS{
	FOLLOW, 
	SING, 
}


func _ready() -> void :
	alarm.hide()
	mainWindow.min_size = player_size
	mainWindow.size = mainWindow.min_size
	mainWindow.position = Vector2i(DisplayServer.screen_get_size().x / 2 - (player_size.x / 2), taskbar_pos + 25)
	menu.add_item("Follow mouse", Menu_IDS.FOLLOW)
	menu.add_item("Sing a Song", Menu_IDS.SING)
	# BIG/LOUD songs: boost sing player so songs are clearly audible
	audio.volume_db = SONG_VOLUME_DB
	audio.bus = "Master"
	if not audio.finished.is_connected(_on_song_finished):
		audio.finished.connect(_on_song_finished)


# --- No-repeat shuffle: every "Sing a Song" plays a new song ---
# Builds a shuffled bag of available songs; pops one per request.
# Only refills (re-shuffles) once every song has played -> never repeats early.
func _get_available_songs() -> Array:
	var available: Array = []
	for path in songs:
		if ResourceLoader.exists(path):
			available.append(path)
	# Safety fallback: if popular placeholders are missing, still use keepers
	if available.is_empty():
		available = ["res://assets/Audio/song_egg.mp3", "res://assets/Audio/song_horse.mp3"]
	return available

func _refill_song_queue() -> void :
	var available := _get_available_songs()
	# Avoid immediate repeat across refills: last played must not be popped first.
	# We pop from the BACK, so ensure the back element != last_song.
	if last_song != "" and available.size() > 1 and available.has(last_song):
		available.shuffle()
		if available[available.size() - 1] == last_song:
			var swap_idx := randi_range(0, available.size() - 2)
			var tmp = available[available.size() - 1]
			available[available.size() - 1] = available[swap_idx]
			available[swap_idx] = tmp
	else:
		available.shuffle()
	song_queue = available

func get_next_song() -> String:
	if song_queue.is_empty():
		_refill_song_queue()
	last_song = song_queue.pop_back()
	return last_song

func play_next_song() -> void :
	song = get_next_song()
	audio.stream = load(song)
	audio.volume_db = SONG_VOLUME_DB
	audio.play()

func _on_song_finished() -> void :
	# Auto-advance while in singing mode so one click = continuous non-repeating jukebox
	if singing:
		if song_queue.is_empty() and _get_available_songs().size() <= 1:
			anim.play("idle_blink")
			singing = false
			menu.set_item_text(Menu_IDS.SING, "Sing a Song")
		else:
			play_next_song()
			if anim.current_animation != "sing":
				anim.play("sing")


func _process(delta: float) -> void :
	if follow:
		follow_mouse()
	elif picked:
		if mainWindow.position.x >= screen_width / 2:
			char_sprite.flip_h = true
		else:
			char_sprite.flip_h = false
		drag()
	if is_walking:
		walk(delta)

func follow_mouse() -> void :
	if mouse_offset.y > 0 and prev.y < 0:
		anim.play("walk_diag_dwn")
	elif mouse_offset.y < 0 and prev.y > 0:
		anim.play("walk_diag_up")
	if mouse_offset.x > 0 and prev.x < 0:
		char_sprite.flip_h = false
	elif mouse_offset.x < 0 and prev.x > 0:
		char_sprite.flip_h = true
	prev = mouse_offset
	mouse_offset = Vector2((DisplayServer.mouse_get_position().x - mainWindow.position.x - player_size.x / 2), (DisplayServer.mouse_get_position().y - mainWindow.position.y - player_size.y / 2))
	mouse_offset = Vector2(mouse_offset.x * 5 / mouse_offset.length(), mouse_offset.y * 5 / mouse_offset.length())
	if (abs(mouse_offset.x) > 2 or abs(mouse_offset.y) > 2) and abs(mouse_offset.x) != 5:
		mainWindow.position = Vector2(clamp_width(mainWindow.position.x + mouse_offset.x), clamp_height(mainWindow.position.y + mouse_offset.y))

func drag() -> void :
	mainWindow.position = Vector2(DisplayServer.mouse_get_position().x - player_size.x / 2, DisplayServer.mouse_get_position().y - player_size.y / 2)

func clamp_height(pos):
	return clampi(pos, 25, taskbar_pos + 25)

func clamp_width(pos):
	return clampi(pos, 0, screen_width - player_size.x)

func walk(delta: float) -> void :
	if !picked:
		mainWindow.position.x = mainWindow.position.x + WALK_SPEED * delta * walk_direction
		mainWindow.position.y = mainWindow.position.y + WALK_SPEED * delta * up_direction
		mainWindow.position.x = clampi(mainWindow.position.x, 0, clamp_width(mainWindow.position.x))
		mainWindow.position.y = clampi(mainWindow.position.y, 0, clamp_height(mainWindow.position.y))
		if (mainWindow.position.x >= (screen_width - player_size.x)) or (mainWindow.position.x == 0):
			walk_direction = walk_direction * -1
			char_sprite.flip_h = !char_sprite.flip_h
		if (mainWindow.position.y <= 50) or (mainWindow.position.y >= taskbar_pos + 25):
			up_direction = up_direction * -1
		if up_direction == 1:
			anim.play("walk_diag_dwn")
		else:
			anim.play("walk_diag_up")

func choose_direction():
	match randi_range(1, 4):
		1:
			walk_direction = 1
			char_sprite.flip_h = false
			up_direction = 1
		2:
			walk_direction = 1
			char_sprite.flip_h = false
			up_direction = -1
		3:
			walk_direction = -1
			char_sprite.flip_h = true
			up_direction = 1
		4:
			walk_direction = -1
			char_sprite.flip_h = true
			up_direction = -1

func _on_walking() -> void :
	timer.start()
	timer.set_wait_time(1.4)

func _on_not_walking() -> void :
	is_walking = false

func _on_timer_timeout() -> void :
	if anim.current_animation != "intro_anim" and !emit.emitting and !is_walking:
		is_walking = true
		choose_direction()
	elif alarm_bool:
		if alarm.color == color[0]:
			alarm.color = color[1]
		else:
			alarm.color = color[0]

func _input(_event):
	if Input.is_action_just_pressed("menu"):
		last_mp = DisplayServer.mouse_get_position()
		menu.popup(Rect2(last_mp, menu_size))
	if Input.is_action_just_pressed("pet"):
		emit.set_emitting(true)
	if Input.is_action_just_released("pet"):
		emit.set_emitting(false)


	elif Input.is_action_just_pressed("move"):
		if alarm_bool:
			_on_bmo_alert_off()
		if is_walking:
			is_walking = false
			anim.play("idle_blink")
		if anim.current_animation == "sleep_loop":
			anim.play("sleep_end")
		elif !anim.is_playing() and !picked and !follow:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			anim.play("pickup_lift")
			anim.queue("pickup_loop")
			picked = true
		elif picked:
			anim.play("pickup_end")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			picked = false

func _on_popup_menu_id_pressed(id: int) -> void :
	match id:
		Menu_IDS.FOLLOW:
			if !anim.is_playing():
				follow = true
				menu.set_item_text(id, "Stop following")
			elif follow and anim.current_animation in ["walk_diag_up", "walk_diag_dwn", "walk_get_up"]:
				follow = false
				anim.play("idle_blink")
				menu.set_item_text(id, "Follow mouse")
		Menu_IDS.SING:
			if !anim.is_playing():
				singing = true
				play_next_song()
				anim.play("sing")
				menu.set_item_text(id, "Stop singing")
			elif singing:
				menu.set_item_text(id, "Sing a Song")
				singing = false
				anim.play("idle_blink")
				audio.stop()

func _on_bmo_alert_on() -> void :
	alarm.show()
	timer.set_wait_time(0.1666666667)
	mainWindow.size = Vector2(5000, 5000)
	mainWindow.position = Vector2(0, 0)
	alarm_bool = true

func _on_bmo_alert_off() -> void :
	alarm.hide()
	mainWindow.size = mainWindow.min_size
	anim.play("idle_danger_end")
	alarm_bool = false
