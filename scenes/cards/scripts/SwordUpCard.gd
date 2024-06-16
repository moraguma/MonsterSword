extends Card


const TEST_ENEMY = preload("res://scenes/entities/SwordUp.tscn")


func _ready():
	set_tooltip("Deals 4 damage to the selected entity and spawns a 3HP 2ATK sword on their team")


func play(entity: Entity):
	await entity.get_attacked(battle.player, 4)
	
	var enemy = TEST_ENEMY.instantiate()
	if entity.team == Entity.TEAM.ENEMY:
		battle.add_enemy(enemy, battle.get_entity_position(entity) + 1)
	else:
		battle.add_ally(enemy, battle.get_entity_position(entity) + 1)
