extends "res://scenes/BattleScene/Item/Item.gd"

func put_effect(player: CharacterBody2D):
	player.max_bomb += 1
	player.left_bomb += 1
