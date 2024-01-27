extends Area2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	animated_sprite_2d.frame = 0

func _on_body_entered(body):
	collision_shape_2d.call_deferred("set_disabled", true)
	animated_sprite_2d.play("fade")
	await animated_sprite_2d.animation_finished
	queue_free()
	Events.heart_collected.emit()
	var hearts = get_tree().get_nodes_in_group("Hearts") #An array
	if hearts.size() == 1:
		Events.level_completed.emit()
		print("Level Completed")
