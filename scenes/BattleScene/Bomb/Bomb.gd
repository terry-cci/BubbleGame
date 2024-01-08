extends StaticBody2D

signal exploded(bomb_position: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	var battle_scene = get_parent().get_parent()
	if battle_scene and battle_scene.has_method('_on_bomb_exploded'):
		exploded.connect(battle_scene._on_bomb_exploded)
	



func _on_fuse_timer_timeout():
	exploded.emit(global_position)
