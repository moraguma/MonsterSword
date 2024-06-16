extends Entity


func _ready():
	var effect = preload("res://scenes/effects/Heal.tscn").instantiate()
	effect.initialize(1)
	add_effect(effect)
	super()
