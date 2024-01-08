extends "res://scenes/BattleScene/Item/Item.gd"

func put_effect(player: CharacterBody2D):
	player.bomb_power = min(player.bomb_power + 1,2)
