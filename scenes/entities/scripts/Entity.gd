extends Sprite2D
class_name Entity

enum TEAM {ALLY, ENEMY}
enum AIM_TYPES {ATTACK}

const DAMAGE_COLOR = Color.WHITE
const HEAL_COLOR = Color.GREEN
const EFFECT_DISPLAY = preload("res://scenes/EffectDisplay.tscn")
const INTENT_SCENE = preload("res://scenes/Intent.tscn")
const ATTACK_TEX = preload("res://resources/sprites/effects/attack.png")

const ANIMATION_MOVEMENT = 8
const LERP_WEIGHT = 0.1
const BLINK_HALF_TIME = 0.1
const INTENT_MAX_SPACING = 48
const EFFECT_MAX_SPACING = 48

@export var life: int
@export var max_life: int
@export var attack: int
var effects: Array[Effect]
var effect_displays: Array
@onready var effect_container: Node2D = $StatsHolder/Effects

@export var icon: Texture

var team: TEAM
var attack_aim: Entity
var selected = false
var alive = true

var intents: Array[Intent] = []
@onready var intent_container: Node2D = $IntentHolder/Intents

@onready var battle: Battle = get_parent().get_parent()


@onready var indicator: Sprite2D = $Indicator

@onready var stats_holder: Node2D = $StatsHolder
@onready var life_display: Label = $StatsHolder/HP
@onready var attack_display: Label = $StatsHolder/ATK

@onready var intent_holder: Node2D = $IntentHolder
@onready var turn_timer: Label = $IntentHolder/TurnTimer


func _ready():
	material = material.duplicate()
	intent_holder.position[1] = -texture.get_height() / 2
	stats_holder.position[1] = texture.get_height() / 2
	update_values()


func _process(delta):
	offset = lerp(offset, Vector2(0, 0), LERP_WEIGHT)


func update_values():
	life_display.text = str(life) + "/" + str(max_life)
	attack_display.text = str(attack)


## Called at the start of the player's turn. Returns true if this entity intends
## on doing something and false otherwise
func process_intent():
	intents = []
	for child in intent_container.get_children():
		child.queue_free()
	
	var intent_loaded = false
	
	# Process effect intents
	for effect: Effect in effects:
		if effect.process_intent():
			intent_loaded = true
	
	var adversaries = battle.get_attackable_adversaries(self)
	if attack > 0 and len(adversaries) > 0:
		attack_aim = adversaries[randi() % len(adversaries)]
		display_intent(attack_aim, ATTACK_TEX)
		intent_loaded = true
	else:
		attack_aim = null
	
	battle.space_elements(intents, len(intents), len(intents), INTENT_MAX_SPACING)
	return intent_loaded


## Called at the entity's turn
func turn():
	for effect in effects:
		if await effect.turn():
			await battle.sleep()
		if not alive:
			return
	
	if attack_aim == null:
		return
	
	animate()
	await attack_aim.get_attacked(self, attack)


func get_attacked(entity: Entity, damage: int):
	life -= damage
	update_values()
	
	material.set_shader_parameter("color", DAMAGE_COLOR)
	await blink()
	
	if life <= 0:
		battle.kill_entity(self)


func heal(value):
	life = min(max_life, life + value)
	
	material.set_shader_parameter("color", HEAL_COLOR)
	await blink()


func blink():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_method(set_blink_parameter, 0.0, 1.0, BLINK_HALF_TIME)
	await battle.sleep(BLINK_HALF_TIME)
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_method(set_blink_parameter, 1.0, 0.0, BLINK_HALF_TIME)
	await(battle.sleep(BLINK_HALF_TIME))


func set_blink_parameter(amount):
	material.set_shader_parameter("amount", amount)


func die():
	alive = false
	queue_free() # TODO: Implement dying animation


## Displays aim circle on top of character that displays type of interaction and
## aimed entity
func display_intent(aim: Entity, type: Texture):
	var intent: Intent = INTENT_SCENE.instantiate()
	intent.initialize(aim, type)
	intents.append(intent)
	intent_container.add_child(intent)


func add_effect(effect: Effect):
	for e in effects:
		if e.icon == effect.icon:
			e.value += effect.value
			for d in effect_container.get_children():
				if d.texture == effect.icon:
					d.update_value(effect.value)
					break
			return
	
	effect.entity = self
	effects.append(effect)
	
	var display = EFFECT_DISPLAY.instantiate()
	effect_container.add_child(display)
	display.initialize(effect.icon, effect.value)
	effect_displays.append(display)
	
	battle.space_elements(effect_displays, len(effects), len(effects), EFFECT_MAX_SPACING)


func delete_effect(effect: Effect):
	effects.erase(effect)
	for d in effect_container.get_children():
		if d.texture == effect.icon:
			effect_displays.erase(d)
			d.queue_free()
	battle.space_elements(effect_displays, len(effects), len(effects), EFFECT_MAX_SPACING)


func pressed():
	if not selected:
		if battle.select_entity(self):
			selected = true
			indicator.show()
	else:
		selected = false
		indicator.hide()
		battle.desselect_entity(self)


func set_order(value: int):
	turn_timer.text = str(value)


func delete_order():
	turn_timer.text = ""


func animate():
	offset += ANIMATION_MOVEMENT * (Vector2(1, 0) if team == TEAM.ENEMY else Vector2(-1, 0)) 
