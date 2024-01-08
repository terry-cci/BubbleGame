extends Control

@onready var scene = preload('res://scenes/TitleScene/TitleScene.tscn')

func _on_button_pressed():
	get_tree().change_scene_to_packed(scene)
