extends Card


const ARMOR = preload("res://scenes/entities/ArmorUp.tscn")


func _ready():
	set_tooltip("Deals 10 damage to the selected entity and spawns a 10HP protective armor on their team")


func play(entity: Entity):
	await entity.get_attacked(battle.player, 10)
	
	var enemy = ARMOR.instantiate()
	if entity.team == Entity.TEAM.ENEMY:
		battle.add_enemy(enemy, battle.get_entity_position(entity) + 1)
	else:
		battle.add_ally(enemy, battle.get_entity_position(entity) + 1)
