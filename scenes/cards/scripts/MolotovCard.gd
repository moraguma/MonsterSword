extends Card


const ENTITY = preload("res://scenes/entities/Molotov.tscn")


func _ready():
	upgrade_card = preload("res://scenes/cards/MolotovUpCard.tscn")
	set_tooltip("Heals the selected entity for 5 HP and spawns a 5HP Explode 5 skull on their team")


func play(entity: Entity):
	await entity.heal(5)
	
	var enemy = ENTITY.instantiate()
	if entity.team == Entity.TEAM.ENEMY:
		battle.add_enemy(enemy, battle.get_entity_position(entity) + 1)
	else:
		battle.add_ally(enemy, battle.get_entity_position(entity) + 1)
