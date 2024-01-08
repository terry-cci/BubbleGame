extends "res://scenes/BattleScene/Item/Item.gd"

func put_effect(player: CharacterBody2D):
	player.left_lives += 1
