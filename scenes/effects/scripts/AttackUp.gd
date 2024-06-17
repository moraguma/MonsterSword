extends Effect


var target = null


func _ready():
	tooltip.tooltip_text = "Modifies this entity's attack by X"
	super()


## Called when entity receives effect. Should register to any needed signals
func attach(new_entity: Entity):
	super(new_entity)
	entity.attack += value
	entity.update_values()


func update_value(value):
	if value > 0:
		SoundController.play_sfx("Buff")
	else:
		SoundController.play_sfx("Debuff")
	
	super(value)
	
	entity.attack += value
	entity.update_values()
