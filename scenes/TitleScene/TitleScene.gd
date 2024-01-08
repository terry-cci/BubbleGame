extends Control



func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/BattleScene/BattleScene.tscn")


func _on_label_gui_input(event: InputEvent):
	print("!")
	if event.is_action('ui_click', true):
		OS.shell_open("https://github.com/terry-cci")


func _on_help_button_pressed():
	get_tree().change_scene_to_file('res://scenes/HelpScene/HelpScene.tscn')
