extends RefCounted
class_name KrakoutRandom

const MULTIPLIER := 8121
const INCREMENT := 28411
const MODULUS := 134456

var state := 0


func _init(seed_value: int = 0) -> void:
	state = seed_value


func set_seed(seed_value: int) -> void:
	state = seed_value


func next_state() -> int:
	state = (INCREMENT + state * MULTIPLIER) % MODULUS
	return state


func next_mod(modulus: int) -> int:
	if modulus <= 0:
		return 0
	return next_state() % modulus
