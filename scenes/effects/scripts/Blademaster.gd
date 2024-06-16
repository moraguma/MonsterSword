extends Effect


var target = null


func _ready():
	tooltip.tooltip_text = "Each turn, raises the attack of a random ally by X"
	super()


## Called at the start of player's turn. Returns true if loaded any intent and
## false otherwise
func process_intent():
	var allies = entity.battle.get_allies(entity)
	
	var aim_idx = randi() % len(allies)
	target = allies[aim_idx]
	
	entity.display_intent(target, texture, "Will raise the attack of %s number %s by %s" % ["enemy" if entity.team == Entity.TEAM.ENEMY else "ally", aim_idx + 1, value])
	return true


## Called in the attached entity's turn. Returns true if an action was performed
## and false otherwise
func turn():
	var attack_up = preload("res://scenes/effects/AttackUp.tscn").instantiate()
	attack_up.value = value
	entity.animate()
	await entity.battle.try_to_call_on_entity(target, "add_effect", [attack_up])
	
	target = null
