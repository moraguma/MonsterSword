extends Card


const ENTITY = preload("res://scenes/entities/MolotovUp.tscn")


func _ready():
	set_tooltip("Heals the selected entity for 12HP and spawns a 3HP very volatile skull on their team")


func play(entity: Entity):
	await entity.heal(8)
	
	var enemy = ENTITY.instantiate()
	if entity.team == Entity.TEAM.ENEMY:
		battle.add_enemy(enemy, battle.get_entity_position(entity) + 1)
	else:
		battle.add_ally(enemy, battle.get_entity_position(entity) + 1)
