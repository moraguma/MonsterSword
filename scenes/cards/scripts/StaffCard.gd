extends Card


const STAFF = preload("res://scenes/entities/Staff.tscn")


func play(entity: Entity):
	await entity.heal(2)
	
	var enemy = STAFF.instantiate()
	if entity.team == Entity.TEAM.ENEMY:
		battle.add_ally(enemy, battle.get_entity_position(entity) + 1)
	else:
		battle.add_enemy(enemy, battle.get_entity_position(entity) + 1)
