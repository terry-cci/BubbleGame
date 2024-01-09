extends "res://scenes/BattleScene/Bomber/Bomber.gd"

@export var target: CharacterBody2D

@onready var nav_agent := $Navigation/NavigationAgent2D as NavigationAgent2D

@onready var cell_danger_map := get_parent().get_parent().cell_danger as Dictionary
@onready var player_list := get_parent().get_parent().players as Array[CharacterBody2D]
	
var rng = RandomNumberGenerator.new()

func find_nearest_safe_cell(origin: Vector2i):
	var cell_checked = {}
	var cells_to_check: Array[Vector2i] = [origin]
	while not cells_to_check.is_empty():
		var cell = cells_to_check.pop_front()	
		cell_checked[cell] = true
		
		if cell_danger_map.get(cell, 0) == 0:
			return cell
			
		for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			if get_tile_source_id(cell + direction) == 6 and not cell_checked.get(cell+direction, false):
				cells_to_check.push_back(cell + direction)
	return origin
	
	
var safe_velocity: Vector2
	

func get_bomber_speed():
	if not target:
		var left_players: Array = player_list.filter(func (player): return player != null and player != self)
		if left_players.size():
			target = left_players[0]
	
	# if standing on a dangerous cell
	if (cell_danger_map.get(get_coords(), 0) != 0 or cell_danger_map.get(get_coords() + facing_direction, 0) != 0) and rng.randf() >0.03:
		#if name=='Enemy':
			#print(cell_danger_map)
		var dest = find_nearest_safe_cell(get_coords())
		nav_agent.target_position = tile_map.to_global(tile_map.map_to_local(dest))
	else:
		if not target:
			return Vector2.ZERO
		#if to_local(target.get_node('BombPlacingPosition').global_position).length() < 20:
			#nav_agent.target_position = global_posistion
		if cell_danger_map.get(get_coords() - facing_direction, 0) == 0 and rng.randf() > 0.5:
			nav_agent.target_position = target.get_node('BombPlacingPosition').global_position
		else:
			if (cell_danger_map.get(get_coords() + facing_direction, 0) == 0 and get_tile_source_id(get_coords() + facing_direction) == 6 and rng.randf() > 0.5) or rng.randf() < 0.01:
				nav_agent.target_position = tile_map.to_global(tile_map.map_to_local(get_coords() + facing_direction))
			
		
	var direction: Vector2 = Vector2.ZERO if nav_agent.is_navigation_finished() else $Navigation.to_local(nav_agent.get_next_path_position())
		 
	
	

	#var space_state = get_world_2d().direct_space_state
	#var ray_position = facing_direction
	#ray_position.x *= 32
	#ray_position.y *= 32 if ray_position.y > 0 else 32


	#var query = PhysicsRayQueryParameters2D.create($BombPlacingPosition.global_position, $BombPlacingPosition.global_position + ray_position, 0b0010, [self])
	#var result = space_state.intersect_ray(query)
	#if result and not is_dead and (left_bomb == DEFAULT_BOMB or (to_local(last_bomb_position).length() > 120 and left_bomb > 0)):
		#bomb_placed.emit(to_global($BombPlacingPosition.position), bomb_power, self)
		#last_bomb_position = $BombPlacingPosition.global_position
		#print("bomb_placed")

	#else:
		#if name == 'Enemy':
			#print(name ,result, is_dead, left_bomb)
	
	nav_agent.set_velocity(direction.normalized() * speed)
			
	#if name=='Enemy':
		#print(direction.normalized() * SPEED, safe_velocity)

	if safe_velocity.length() < 10:
		#print(get_coords(), facing_direction)
		#print(get_tile_source_id(get_coords() + facing_direction))
		if left_bomb > 0 and (get_tile_source_id(get_coords() + facing_direction) == 3 and cell_danger_map.get(get_coords() - facing_direction, 0) == 0):
			bomb_placed.emit(to_global($BombPlacingPosition.position), bomb_power, self)
		if get_tile_source_id(get_coords() + facing_direction) == 0 and rng.randf() > 0.95:
			print('facing wall!')
			print('change to', Vector2(facing_direction).rotated(PI / 2).normalized() * speed)
			return Vector2(facing_direction).rotated(PI / 2).normalized() * speed
		# check if faced a wall
		return Vector2.ZERO
		
	if left_bomb > 0 and player_list.any(is_player_near):
		bomb_placed.emit(to_global($BombPlacingPosition.position), bomb_power, self)
	
	return safe_velocity * rng.randf_range(1.75,2)

func is_player_near(player):
	return player != null and player != self and (player.get_coords() - get_coords()).length() < bomb_power and not player.is_dead

func _on_navigation_agent_2d_velocity_computed(v):
	safe_velocity = v
