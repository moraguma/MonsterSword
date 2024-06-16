extends Effect


var target = null


func _ready():
	tooltip.tooltip_text = "At the start of its turn, heals a random ally for X health"
	


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
	
	var aim_idx = randi() % len(allies)
	target = allies[aim_idx]
	
	entity.display_intent(target, texture, "Will heal %s number %s for %s HP" % ["enemy" if entity.team == Entity.TEAM.ENEMY else "ally", aim_idx + 1, value])
	return true


## Called in the attached entity's turn. Returns true if an action was performed
## and false otherwise
func turn():
	entity.animate()
	await entity.battle.try_to_call_on_entity(target, "heal", [value])
	
	target = null
