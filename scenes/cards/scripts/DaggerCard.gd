extends Card


const DAGGER = preload("res://scenes/entities/Dagger.tscn")


func _ready():
	upgrade_card = preload("res://scenes/cards/DaggerUpCard.tscn")
	set_tooltip("Lowers the attack of the selected entity by 2 and spawns a 3HP attackmaster 1 dagger on their team")


func play(entity: Entity):
	var effect = preload("res://scenes/effects/AttackUp.tscn").instantiate()
	effect.value = -2
	
	await entity.add_effect(effect)
	
	var enemy = DAGGER.instantiate()
	if entity.team == Entity.TEAM.ENEMY:
		battle.add_enemy(enemy, battle.get_entity_position(entity) + 1)
	else:
		battle.add_ally(enemy, battle.get_entity_position(entity) + 1)
