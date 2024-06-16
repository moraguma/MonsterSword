extends Entity


func _ready():
	var effect = preload("res://scenes/effects/Bomb.tscn").instantiate()
	effect.initialize(5)
	add_effect(effect)
	super()
