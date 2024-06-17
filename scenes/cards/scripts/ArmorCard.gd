extends Card


const ARMOR = preload("res://scenes/entities/Armor.tscn")


func _ready():
	upgrade_card = preload("res://scenes/cards/ArmorUpCard.tscn")
	set_tooltip("Deals 5 damage to the selected entity and spawns a 5HP protective armor on their team")


func play(entity: Entity):
	await entity.get_attacked(battle.player, 5)
	
	var enemy = ARMOR.instantiate()
	if entity.team == Entity.TEAM.ENEMY:
		battle.add_enemy(enemy, battle.get_entity_position(entity) + 1)
	else:
		battle.add_ally(enemy, battle.get_entity_position(entity) + 1)
