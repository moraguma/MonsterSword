extends Entity


@export var val = 1


func _ready():
	var effect = preload("res://scenes/effects/Heal.tscn").instantiate()
	effect.value = val
	add_effect(effect)
	super()
