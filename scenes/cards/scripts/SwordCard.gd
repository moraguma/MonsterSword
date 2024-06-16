extends Card


const TEST_ENEMY = preload("res://scenes/entities/Sword.tscn")


func play(entity: Entity):
	await entity.get_attacked(battle.player, 2)
	
	var enemy = TEST_ENEMY.instantiate()
	if entity.team == Entity.TEAM.ENEMY:
		battle.add_enemy(enemy, battle.get_entity_position(entity) + 1)
	else:
		battle.add_ally(enemy, battle.get_entity_position(entity) + 1)
