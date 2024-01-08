extends CharacterBody2D

signal bomb_placed(position: Vector2, bomb_power: int, player: CharacterBody2D)

const DEFAULT_SPEED = 200
const DEFAULT_BOMB = 2
const DEFAULT_BOMB_POWER = 1
const DEFAULT_LIVES = 1

var speed = DEFAULT_SPEED
var max_bomb = DEFAULT_BOMB

@export var bomb_scene: PackedScene
@export var player_panel: Panel
@onready var tile_map := get_parent() as TileMap

var left_bomb = DEFAULT_BOMB
var bomb_power = DEFAULT_BOMB_POWER
var left_lives = DEFAULT_LIVES
var is_dead = false;

var facing_direction := Vector2i.ZERO

func increase_bomb_count():
	left_bomb += 1
	
func decrease_bomb_count():
	left_bomb -= 1

func get_bomber_speed():
	return Vector2.ZERO
	
func get_coords(query_position: Vector2 = $BombPlacingPosition.global_position) -> Vector2i:
	return tile_map.local_to_map(tile_map.to_local(query_position))

func get_tile_source_id(query_coords: Vector2i) -> int:
	return tile_map.get_cell_source_id(0, query_coords)



func _physics_process(_delta):
	if is_dead:
		return
		
	var bomber_speed: Vector2 = get_bomber_speed()
	if bomber_speed.length():
		velocity = bomber_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	

	if is_inside_tree():
		if bomber_speed.length():
			if bomber_speed.y and velocity.abs().y > 25:
				$AnimatedSprite2D.animation = 'up' if bomber_speed.y <= 0 else 'down'
				facing_direction = Vector2i.UP if bomber_speed.y <= 0 else Vector2i.DOWN
			elif velocity.abs().x > 25:
				$AnimatedSprite2D.animation = 'horizontal'
				$AnimatedSprite2D.scale.x = -1 if bomber_speed.x < 0 else 1
				facing_direction = Vector2i.LEFT if bomber_speed.x < 0 else Vector2i.RIGHT
			if not $AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.frame = 0
				$AnimatedSprite2D.play()
		else:
			$AnimatedSprite2D.stop()
			$AnimatedSprite2D.frame = 2
	move_and_slide()

func _process(_delta):
	player_panel.get_node("BombCountLabel").text = "%d/%d" % [left_bomb, max_bomb]
	player_panel.get_node("ExplosionLabel").text = "Lv%d" % bomb_power
	player_panel.get_node("ShieldLabel").text = "%d" % max(0, left_lives - 1)

		
func _on_hurt():
	if is_dead:
		return
		

	
	if not ($ImmuneTimer as Timer).is_stopped():
		return
		
	print("hurt")
	($HurtAnimationPlayer as AnimationPlayer).play('hurt')
	$HurtAudio.play()
		
	($ImmuneTimer as Timer).start()
	
	left_lives -= 1
	if left_lives <= 0:
		($AnimatedSprite2D as AnimatedSprite2D).animation = 'death'
		$DeathAudio.play()
		player_panel.get_node("AliveLabel").text = "Dead"
		player_panel.modulate = Color(0.5,0.5,0.5,1)
		is_dead = true


func _on_immune_timer_timeout():
	($HurtAnimationPlayer as AnimationPlayer).stop()
	(($AnimatedSprite2D as AnimatedSprite2D).material as ShaderMaterial).set_shader_parameter('hit_opacity', 0)
	if is_dead:
		queue_free()
	


func _on_bomb_placed(_bomb_position, _bomb_power, _player):
	$PlantBombAudio.play()
