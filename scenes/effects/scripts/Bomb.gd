extends Effect


var target = null


func _ready():
	tooltip.tooltip_text = "Upon death, deals X damage to all its allies"
	super()


## Called when entity receives effect. Should register to any needed signals
func attach(new_entity: Entity):
	super(new_entity)
	entity.death_calls.append(self)


func die():
	var allies = entity.battle.get_allies(entity)
	for ally in allies:
		if ally != self:
			await ally.get_attacked(entity, value)
