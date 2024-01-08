extends Area2D


signal animation_finished(explosion_position: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	($AnimatedSprite2D as AnimatedSprite2D).play()
	$AudioStreamPlayer2D.play()
	
	var battle_scene = get_parent().get_parent()
	if battle_scene and battle_scene.has_method('_on_explosion_animation_finished'):
		animation_finished.connect(battle_scene._on_explosion_animation_finished)


func _on_animated_sprite_2d_animation_looped():
	animation_finished.emit(global_position)


func _on_body_entered(body: Node2D):
	if body.has_method('_on_hurt'):
		body._on_hurt()
