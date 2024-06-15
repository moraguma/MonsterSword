extends Node2D
class_name Battle


signal played


const PLAYER_SCENE = preload("res://scenes/Player.tscn")
const SMALL_SLEEP_TIME = 0.2
const DEFAULT_SLEEP_TIME = 0.6


const MAX_CARDS = 5
const LERP_WEIGHT = 0.1

const TOTAL_ENTITY_SPACING = 160
const TOTAL_CARD_SPACING = 300

var selected_cards: Array[Card] = []
var selected_entity: Entity = null

var deck: Array[Card] = []
var hand: Array[Card] = []
var allies: Array[Entity] = []
var enemies: Array[Entity] = []
var turn_order: Array[Entity] = []

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

@onready var sleep_timer: Timer = $SleepTimer

var can_interact = false
var can_play = false
var can_discard = false
@onready var missing_card_error: RichTextLabel = $Discard/MissingCard
@onready var select_card_error: RichTextLabel = $Play/SelectCard
@onready var select_entity_error: RichTextLabel = $Play/SelectEntity


func fisher_yates_shuffle(l):
	var n = len(l)
	
	for i in range(n - 1):
		var j = randi() % (n - i) + i
		var aux = l[j]
		l[j] = l[i]
		l[i] = aux


func initialize(battle_enemies: Array, deck: Array[Card]):
	self.deck = deck
	for enemy in battle_enemies:
		add_enemy(enemy, enemies.size())


func _ready():
	var test_card = preload("res://scenes/cards/TestCard.tscn")
	var test_deck: Array[Card] = []
	for i in range(10):
		test_deck.append(test_card.instantiate())
	var test_enemy = preload("res://scenes/entities/TestEnemy.tscn")
	var test_enemies: Array[Entity] = []
	for i in range(2):
		test_enemies.append(test_enemy.instantiate())
	initialize(test_enemies, test_deck)
	
	player = PLAYER_SCENE.instantiate()
	add_ally(player, 0)
	fisher_yates_shuffle(deck)
	
	for i in range(MAX_CARDS):
		pull_from_deck()
	
	update_play()
	update_discard()
	while len(enemies) != 0 and player in allies:
		await process_intents()
		
		can_interact = true
		await played
		
		for entity in turn_order:
			if entity != null:
				await entity.turn()
				await sleep()
	
	if not player in allies:
		print("GAME OVER")
	else:
		print("VICTORY")


func process_intents():
	turn_order = []
	var order = 1
	if player.process_intent():
		turn_order.append(player)
		player.set_order(order)
		order += 1
		await sleep(SMALL_SLEEP_TIME)
	
	for container in [ally_container, enemy_container]:
		for entity in container.get_children():
			if entity != player:
				if entity.process_intent():
					turn_order.append(entity)
					entity.set_order(order)
					order += 1
					await sleep(SMALL_SLEEP_TIME)
	
	return turn_order


func _process(delta):
	ally_visual_count = space_elements(allies, aim_ally_visual_count, ally_visual_count, TOTAL_ENTITY_SPACING)
	enemy_visual_count = space_elements(enemies, aim_enemy_visual_count, enemy_visual_count, TOTAL_ENTITY_SPACING)
	card_visual_count = space_elements(hand, aim_card_visual_count, card_visual_count, TOTAL_CARD_SPACING)


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
	if len(hand) < MAX_CARDS and len(deck) > 0:
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
	
	aim_card_visual_count -= 1


func kill_entity(entity: Entity):
	var turn_pos = turn_order.find(entity)
	if turn_pos != -1:
		turn_order[turn_pos] = null
	
	var list: Array[Entity]
	var container: XSort
	if entity.team == Entity.TEAM.ALLY:
		list = allies
		container = ally_container
		aim_ally_visual_count -= 1
	else:
		list = enemies
		container = enemy_container
		aim_enemy_visual_count -= 1
	
	list.erase(entity)
	container.remove_child(entity)
	entity.die()


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


#region Interaction
func select_card(card: Card):
	if not can_interact:
		return false
	
	selected_cards.append(card)
	update_play()
	update_discard()
	return true


func desselect_card(card: Card):
	selected_cards.erase(card)
	update_play()
	update_discard()


func select_entity(entity: Entity):
	if not can_interact:
		return false
	
	if selected_entity != null:
		selected_entity.pressed()
	selected_entity = entity
	update_play()
	return true


func desselect_entity(entity: Entity):
	selected_entity = null
	update_play()


func update_play():
	if len(selected_cards) == 0 or len(selected_cards) > 1:
		select_card_error.show()
		can_play = false
		return
	select_card_error.hide()
	
	if selected_entity == null:
		select_entity_error.show()
		can_play = false
		return
	select_entity_error.hide()
	
	can_play = true


func update_discard():
	if len(selected_cards) < 1 or len(selected_cards) > 2:
		missing_card_error.show()
		can_discard = false
		return
	missing_card_error.hide()
	
	can_discard = true


func play():
	if not can_play:
		return
	can_play = false
	
	var entity = selected_entity
	var card = selected_cards[0]
	selected_entity.pressed()
	card.pressed()
	
	can_interact = false
	
	await card.play(entity)
	
	pull_from_deck()
	
	played.emit()


func discard():
	if not can_discard:
		return
	can_discard = false
	
	var cards = selected_cards.duplicate()
	if selected_entity != null:
		selected_entity.pressed()
	for card in cards:
		card.pressed()
	
	can_interact = false
	
	var cards_to_pull = len(cards)
	for i in range(cards_to_pull):
		discard_card(cards.pop_back())
		await sleep(SMALL_SLEEP_TIME)
	
	for i in range(cards_to_pull):
		pull_from_deck()
		await sleep(SMALL_SLEEP_TIME)
	
	played.emit()
#endregion


func sleep(time: float=DEFAULT_SLEEP_TIME):
	sleep_timer.start(time)
	await sleep_timer.timeout


func get_attackable_adversaries(entity: Entity):
	var targets = allies.duplicate() if entity.team == entity.TEAM.ENEMY else enemies.duplicate()
	return targets
