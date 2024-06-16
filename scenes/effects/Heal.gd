extends Effect


var target = null


func _init():
	icon = preload("res://resources/sprites/effects/heal.png")


## Called when entity receives effect. Should register to any needed signals
func attach(new_entity: Entity):
	entity = new_entity


## Called at the start of player's turn. Returns true if loaded any intent and
## false otherwise
func process_intent():
	var allies = entity.battle.get_allies(entity)
	
	var unhealthy_allies = []
	for ally in allies:
		if ally.life < ally.max_life:
			unhealthy_allies.append(ally)
	if len(unhealthy_allies) > 0:
		allies = unhealthy_allies
	
	target = allies[randi() % len(allies)]
	
	entity.display_intent(target, icon)
	return true


## Called in the attached entity's turn. Returns true if an action was performed
## and false otherwise
func turn():
	await entity.battle.try_to_call_on_entity(target, "heal", [value])
	
	target = null
