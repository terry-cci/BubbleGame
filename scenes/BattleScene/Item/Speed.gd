extends "res://scenes/BattleScene/Item/Item.gd"

func put_effect(player: CharacterBody2D):
	player.speed = min(player.speed + 15,400 )
