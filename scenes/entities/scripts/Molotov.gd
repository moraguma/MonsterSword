extends Entity


@export var val = 5


func _ready():
	var effect = preload("res://scenes/effects/Bomb.tscn").instantiate()
	effect.value = val
	add_effect(effect)
	super()
