extends Entity


@export var val = 1


func _ready():
	var effect = preload("res://scenes/effects/Blademaster.tscn").instantiate()
	effect.initialize(val)
	add_effect(effect)
	super()
