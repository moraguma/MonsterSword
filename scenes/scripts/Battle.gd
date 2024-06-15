extends Node2D
class_name Battle


const PLAYER_SCENE = preload("res://scenes/Player.tscn")


const MAX_CARDS = 5
const LERP_WEIGHT = 0.1

const TOTAL_ENTITY_SPACING = 160
const TOTAL_CARD_SPACING = 300


var deck: Array[Card] = []
var hand: Array[Card] = []
var allies: Array[Entity] = []
var enemies: Array[Entity] = []

var player: Entity

var ally_visual_count = 0
var aim_ally_visual_count = 0
var enemy_visual_count = 0
var aim_enemy_visual_count = 0
var card_visual_count = 0
var aim_card_visual_count = 0

@onready var ally_container: XSort = $Allies
@onready var enemy_container: XSort = $Enemies
@onready var card_container: XSort = $Cards


func fisher_yates_shuffle(l):
	var n = len(l)
	
	for i in range(n - 1):
		var j = randi() % (n - i) + i
		var aux = l[j]
		l[j] = l[i]
		l[i] = aux


func initialize(enemies: Array, deck: Array[Card]):
	self.deck = deck
	for enemy in enemies:
		add_enemy(enemy, enemies.size())


func _ready():
	player = PLAYER_SCENE.instantiate()
	add_ally(player, 0)
	fisher_yates_shuffle(deck)


func _process(delta):
	ally_visual_count = space_elements(allies, aim_ally_visual_count, ally_visual_count, TOTAL_ENTITY_SPACING)
	enemy_visual_count = space_elements(enemies, aim_enemy_visual_count, enemy_visual_count, TOTAL_ENTITY_SPACING)
	card_visual_count = space_elements(hand, aim_card_visual_count, card_visual_count, TOTAL_ENTITY_SPACING)


func space_elements(elements: Array, aim_visual_counter: float, visual_counter: float, total_spacing: float):
	if visual_counter < 1:
		visual_counter = 1
	
	var spacing = total_spacing / (visual_counter + 1)
	var start = -total_spacing / 2
	for element in elements:
		start += spacing
		element.position[0] = start
	
	return lerp(visual_counter, aim_visual_counter, LERP_WEIGHT)


#region Element management
func pull_from_deck():
	if len(hand) < MAX_CARDS:
		var card = deck.pop_back()
		if card != null:
			add_card(card)


func add_card(card: Card):
	hand.append(card)
	card_container.add_child(card)
	
	aim_card_visual_count += 1


func discard_card(card: Card):
	hand.erase(card)
	card.queue_free() # TODO: Add proper animation


func kill_entity(entity: Entity):
	var list: Array[Entity]
	var container: XSort
	if entity.team == Entity.TEAM.ALLY:
		list = allies
		container = ally_container
	else:
		list = enemies
		container = enemy_container
	
	list.erase(entity)
	container.remove_child(entity)
	entity.die()
	
	if entity == player:
		print("Game over") ## TODO: Implement game over logic


func add_entity(entity: Entity, list: Array[Entity], container: Node2D, pos: int, team: Entity.TEAM):
	entity.team = team
	list.insert(pos, entity)
	container.add_child(entity)


func add_ally(ally: Entity, pos: int):
	add_entity(ally, allies, ally_container, pos, Entity.TEAM.ALLY)
	aim_ally_visual_count += 1


func add_enemy(enemy: Entity, pos: int):
	add_entity(enemy, enemies, enemy_container, pos, Entity.TEAM.ENEMY)
	aim_enemy_visual_count += 1
#endregion

func get_attackable_adversaries(entity: Entity):
	var targets = allies.duplicate() if entity.team == entity.TEAM.ENEMY else enemies.duplicate()
	return targets
