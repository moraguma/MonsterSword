extends Card


const STAFF = preload("res://scenes/entities/StaffUp.tscn")


func _ready():
	set_tooltip("Heals an entity for 6 HP and spawns a 4HP Heal 2 staff on their opponents team")


func play(entity: Entity):
	await entity.heal(6)
	
	var enemy = STAFF.instantiate()
	if entity.team == Entity.TEAM.ENEMY:
		battle.add_ally(enemy, len(battle.allies))
	else:
		battle.add_enemy(enemy, len(battle.enemies))
