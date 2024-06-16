extends Entity


func _ready():
	var effect = preload("res://scenes/effects/Protect.tscn").instantiate()
	effect.initialize(0)
	add_effect(effect)
	super()
