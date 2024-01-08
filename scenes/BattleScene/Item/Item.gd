extends Area2D

func _ready():
	($AnimationPlayer as AnimationPlayer).play("float")

func put_effect(player: CharacterBody2D):
	pass

func _on_body_entered(body):
	if body.is_in_group('bomber'):
		body.get_node("GotEffectAudio").play()
		put_effect(body)	
		queue_free()
