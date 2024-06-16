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
	super(value)
	
	entity.attack += value
	entity.update_values()
