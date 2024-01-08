extends "res://scenes/BattleScene/Bomber/Bomber.gd"

func get_bomber_speed():
	return Vector2(Input.get_axis("player1_left", "player1_right"),Input.get_axis("player1_up", "player1_down")).normalized() * speed

func _process(_delta):
	super(_delta)
	 
	if is_dead:
		return
	if Input.is_action_just_pressed("player1_bomb") and left_bomb > 0:
		bomb_placed.emit(to_global($BombPlacingPosition.position), bomb_power, self)
		
	$"../../UI/BombCountLabel".text = "%d/%d" % [left_bomb, max_bomb]
	$"../../UI/ExplosionLabel".text = "Lv%d" % bomb_power
	$"../../UI/ShieldLabel".text = "%d" % max(left_lives - 1, 0)
