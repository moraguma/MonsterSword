extends Card


const TEST_ENEMY = preload("res://scenes/entities/TestEnemy.tscn")


func play(entity: Entity):
	await entity.get_attacked(battle.player, 2)
	
	var enemy = TEST_ENEMY.instantiate()
	if entity.team == Entity.TEAM.ENEMY:
		battle.add_enemy(enemy, 0)
	else:
		battle.add_ally(enemy, 0)
