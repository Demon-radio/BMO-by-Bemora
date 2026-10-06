extends Node2D

@onready var anim = $AnimationPlayer
@onready var time = $Timer
@onready var audio = $AudioStreamPlayer

var bmo_state = STATE.WALK
var prev_state = 1000
var idlers = ["idle_crash", "idle_wave"]
var laughs = ["res://assets/Audio/laugh_1.wav", "res://assets/Audio/laugh_2.wav", "res://assets/Audio/laugh_3.wav"]

enum STATE{
	IDLE, 
	WALK, 
	LOOK, 
	SLEEP, 
	LAUGH, 
	DANGER
}

signal walking
signal not_walking
signal alert_on
signal alert_off


func _ready():
	bmo_state = STATE.WALK
	anim.play("intro_anim")
	time.start()


func _on_time_timeout():

	if anim.current_animation != "intro_anim" and anim.current_animation != "pickup_loop" and anim.current_animation != "sing":
		if bmo_state == STATE.WALK:
			not_walking.emit()
			anim.play("idle_blink")

		elif bmo_state == STATE.SLEEP:
			anim.play("sleep_end")

		elif bmo_state == STATE.DANGER:
			alert_off.emit()
			anim.play("idle_danger_end")

		await state_change()

		match bmo_state:
			STATE.IDLE:
				time.set_wait_time(randi_range(10, 20))
				anim.play(idlers[randi_range(0, len(idlers) - 1)])
			STATE.LOOK:
				time.set_wait_time(randi_range(10, 200))
				anim.play("look")
			STATE.WALK:
				time.set_wait_time(randi_range(10, 200))
			STATE.SLEEP:
				time.set_wait_time(randi_range(10, 200))
				anim.play("sleep_start")
				anim.queue("sleep_loop")
			STATE.LAUGH:
				time.set_wait_time(randi_range(10, 200))
				anim.play("laugh")
				audio.stream = load(laughs[randi_range(0, len(laughs) - 1)])
				audio.play()
			STATE.DANGER:
				if randi_range(0, 100) == 17:
					time.set_wait_time(30)
					anim.play("idle_danger_start")
					anim.queue("idle_danger_loop")
					alert_on.emit()
		time.start()



func _process(delta) -> void :
	if !anim.is_playing():
		if randi_range(0, 1000) == 42:
			anim.play("idle_blink")



func state_change():
	prev_state = bmo_state
	while bmo_state == prev_state:
		bmo_state = randi_range(0, len(STATE))
	if bmo_state == STATE.WALK:
		anim.play("walk_get_up")
		walking.emit()


func _on_audio_stream_player_2d_finished() -> void :
	anim.play("idle_blink")
