extends Entity




func _ready():
	var effect = preload("res://scenes/effects/Blademaster.tscn").instantiate()
	effect.initialize(2)
	add_effect(effect)
	super()
	
	var effect_2 = preload("res://scenes/effects/Heal.tscn").instantiate()
	effect_2.value = 2
	add_effect(effect_2)
	super()
