extends Node

var current_exp: int = 0

var level: int = 1
var level_dict: Dictionary = {
	"1": 25, "2": 33, "3": 49, "4": 66, "5": 93,
	"6": 135, "7": 186, "8": 251, "9": 356
}

func update_exp(value: int) -> void:
	current_exp += value
	
	if current_exp >= level_dict[str(level)] and level < 9:
		var leftover = current_exp - level_dict[str(level)]
		current_exp = leftover
		level_up()
		level += 1
		

func level_up() -> void:
	pass
