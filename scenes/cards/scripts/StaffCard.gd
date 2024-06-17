extends Card


const STAFF = preload("res://scenes/entities/Staff.tscn")


func _ready():
	upgrade_card = preload("res://scenes/cards/StaffUpCard.tscn")
	set_tooltip("Heals an entity for 2 HP and spawns a 2HP Heal 1 staff on their opponents team")


func play(entity: Entity):
	await entity.heal(2)
	
	var enemy = STAFF.instantiate()
	if entity.team == Entity.TEAM.ENEMY:
		battle.add_ally(enemy, len(battle.allies))
	else:
		battle.add_enemy(enemy, len(battle.enemies))
