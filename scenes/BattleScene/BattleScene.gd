extends Node2D

@onready var tile_map:= ($TileMap as TileMap)

var bomb_ownership = {}
var bomb_power_map = {}
var cell_danger = {}

@export var players: Array[CharacterBody2D] = []
@export var available_items: Array[PackedScene] = []

var rng = RandomNumberGenerator.new()

#var debug_labels = {}

func _ready():
	get_tree().paused = true
	#for x in range(1,18):
		#for y in range(1,10):
			#var label = Label.new()
			#label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			#label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			#label.z_index = 30
			#label.set_anchors_preset(Control.PRESET_CENTER)
			#label.global_position = to_global(tile_map.map_to_local(Vector2i(x,y)))
			#label.add_theme_font_size_override('font_size', 16)
			#label.add_theme_color_override('font_color', Color.RED)
			#tile_map.add_child(label)
			#debug_labels[Vector2i(x,y)] = label	
	

func _on_player_bomb_placed(bomb_position, bomb_power, player):
	var map_coords = tile_map.local_to_map(tile_map.to_local(bomb_position))
	if (tile_map.get_cell_source_id(0,map_coords) != 6 and tile_map.get_cell_source_id(0,map_coords) != -1) or tile_map.get_cell_source_id(3,map_coords) != -1:
		return
	
	for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.UP]:
		for distance in range(1,3):
			if tile_map.get_cell_source_id(3,map_coords+direction * distance) == 1:
				for i in range(bomb_power_map.get(map_coords + direction* distance, 0) - distance + 1):
					cell_danger[map_coords - direction * i] = max(cell_danger.get(map_coords - direction * i, 0) - 1, 0)
				
	
	tile_map.set_cell(3,map_coords,1,Vector2i(0,0), 1)
	
	var destroyables = [map_coords]
	for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.UP]:
		destroyables.append_array(get_destroyable_cells(map_coords,direction, bomb_power))
	
	for cell in destroyables:
		cell_danger[cell] = cell_danger.get(cell, 0) + 1
		#if tile_map.get_cell_source_id(0, cell) == 6:
			#tile_map.erase_cell(0, cell)
			#
	#for cell in destroyables:
		#for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.UP]:
			#if tile_map.get_cell_source_id(0, cell + direction) == 6:
				#tile_map.erase_cell(0, cell + direction)
				#tile_map.set_cells_terrain_connect(0, [cell + direction], 0, 0, false)
				
	player.decrease_bomb_count()
	bomb_ownership[map_coords] = player
	bomb_power_map[map_coords] = bomb_power
	
func _on_bomb_exploded(bomb_position: Vector2):
	var map_coords = tile_map.local_to_map(tile_map.to_local(bomb_position))
	var coords_to_be_destroyed: Array[Vector2i] = [map_coords]
	
	if bomb_ownership[map_coords] and bomb_ownership[map_coords] != null:
		bomb_ownership[map_coords].increase_bomb_count()
	bomb_ownership.erase(map_coords)
	
	for direction in [Vector2i(-1,0), Vector2i(1,0), Vector2i(0,-1), Vector2i(0,1)]:
		coords_to_be_destroyed.append_array(get_destroyable_cells(map_coords, direction, bomb_power_map[map_coords]))
		
	bomb_power_map.erase(map_coords)
		
	for coords in coords_to_be_destroyed:
		if tile_map.get_cell_source_id(0,coords) == 3 and rng.randf() > 0.6:
			var to_be_spawned = available_items[rng.randi_range(0, available_items.size() - 1)]
			var item = to_be_spawned.instantiate()
			add_child(item)
			item.global_position = tile_map.to_global(tile_map.map_to_local(coords))
			
		if tile_map.get_cell_source_id(0,coords) == 4:
			cell_danger[coords] = max(cell_danger.get(coords, 0) - 1, 0)
		tile_map.erase_cell(0,coords)
		tile_map.erase_cell(3,coords)
		tile_map.set_cell(0, coords, 4,Vector2i.ZERO, 1)
		tile_map.erase_cell(2, coords + Vector2i.UP)
		
			
		
	
	print(coords_to_be_destroyed)
	
	
	
func get_destroyable_cells(start: Vector2i, direction: Vector2i, limit: int):
	var current: Vector2i = start + direction
	var left_limit = limit
	var cell_coords: Array[Vector2i] = []
	while (tile_map.get_cell_source_id(0, current) == 6 or tile_map.get_cell_source_id(0, current) == 4 or tile_map.get_cell_source_id(0, current) == -1) and tile_map.get_cell_source_id(3, current) == -1  and left_limit > 0:
		cell_coords.push_back(current)
		current += direction
		left_limit -= 1
		
	if tile_map.get_cell_source_id(0, current) == 3 and left_limit > 0:
		cell_coords.push_back(current)
		
	return cell_coords

func _process(_delta):
	#for x in ralabels[coords].text = str(cell_danger.get(coords, 0))
	
	var left_time = ($CountdownTimer as Timer).time_left
	
	if left_time <= 15 and not ($TimeUpAudio as AudioStreamPlayer2D).playing:
		$TimeUpAudio.play()
		
	
	$UI/CountdownLabel.text = "%02d:%02d" % [ floori(left_time / 60), floori(left_time) % 60]
	
	if Input.is_action_just_pressed("ui_pause") and ($StartTimer as Timer).finished:
		get_tree().paused = true
		($PauseMenu as Panel).visible = true
		
	if players[0] == null:
		get_tree().change_scene_to_file("res://scenes/EndScene/GameOver.tscn")
	elif players.filter(func (p): return p != null).size() == 1:
		get_tree().change_scene_to_file("res://scenes/EndScene/EndScene.tscn")

func _on_explosion_animation_finished(explosion_position: Vector2):
	var map_coords = tile_map.local_to_map(tile_map.to_local(explosion_position))
	
	tile_map.erase_cell(0, map_coords)
	
	cell_danger[map_coords] = max(cell_danger.get(map_coords, 0) - 1, 0)
	if rng.randf() > 0.95:
		cell_danger[map_coords] = 0	
	if cell_danger.get(map_coords, 0) == 0:
		cell_danger.erase(map_coords)
	tile_map.set_cells_terrain_connect(0,[map_coords], 0,0, false)
		



func _on_resume_button_pressed():
	get_tree().paused = false
	($PauseMenu as Panel).visible = false


func _on_exit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/TitleScene/TitleScene.tscn")


func _on_restart_button_pressed():
	get_tree().reload_current_scene()


func _on_countdown_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/EndScene/GameOver.tscn")
