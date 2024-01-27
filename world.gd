extends Node2D

@export var next_level: PackedScene


@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var death_screen = $CanvasLayer/DeathScreen
@onready var label = $CanvasLayer/Label
@onready var level_time_label = %LevelTimeLabel


var hearts = []
var hearts_collected = 0

var level_time = 0.0
var start_level_msec = 0.0



func _ready(): 
	if not next_level is PackedScene:
		level_completed.next_level_button.text = "Victory Screen!"
		next_level = load("res://victory_screen.tscn")
	
	get_amount_of_hearts()
	Events.level_completed.connect(show_level_completed)
	Events.heart_collected.connect(update_hearts_collected)
	Events.player_died.connect(player_death)
	hearts_collected = 0
	start_level_msec = Time.get_ticks_msec()

@warning_ignore("unused_parameter")
func _physics_process(delta):
	if Input.is_action_just_pressed("reset"):
		reset_level()
	
	level_time = Time.get_ticks_msec() - start_level_msec
	level_time_label.text = str(level_time / 1000.0)

func go_to_next_level():
	if not next_level is PackedScene: return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()

func show_level_completed():
	level_completed.show()
	level_completed.retry_button.grab_focus()
	get_tree().paused = true

func get_amount_of_hearts():
	var node = get_node("hearts")
	for child in node.get_children():
		if child.is_in_group("Hearts"):
			hearts.append(child)
		
	update_heart_label()

func update_heart_label():
	var score = str(hearts_collected) + "/" + str(hearts.size())
	label.text = score

func update_hearts_collected():
	hearts_collected += 1
	update_heart_label()

func player_death():
	death_screen.show()
	reset_level()
	
func reset_level():
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	if get_tree() != null:
		get_tree().paused = false
		get_tree().reload_current_scene()
		LevelTransition.fade_from_black()

func _on_level_completed_retry():
	reset_level()
	
func _on_level_completed_next_level():
	go_to_next_level()
