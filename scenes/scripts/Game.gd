extends Node2D
class_name Game


signal done


const LERP_WEIGHT = 0.1
const BATTLE = preload("res://scenes/Battle.tscn")

const SLIME = preload("res://scenes/entities/Slime.tscn")
const ZOMBIE = preload("res://scenes/entities/Zombie.tscn")
const SKELETON = preload("res://scenes/entities/Skeleton.tscn")
const MUSHROOM = preload("res://scenes/entities/Mushroom.tscn")
const SKULL = preload("res://scenes/entities/Skull.tscn")
const ROOT = preload("res://scenes/entities/Root.tscn")
const NECRO = preload("res://scenes/entities/Necromancer.tscn")
const BATTLES = {
		0: [
			[SLIME],
			[SLIME, SLIME]
		],
		1: [
			[ZOMBIE, SLIME],
			[SKELETON, SLIME]
		],
		2: [
			[ROOT, SLIME, ZOMBIE],
			[MUSHROOM, SLIME],
			[SKULL, ZOMBIE]
		],
		3: [
			[ROOT, SKULL, SKULL],
			[SKELETON, SKELETON, SLIME],
			[MUSHROOM, ZOMBIE, ZOMBIE]
		]
}
const HARD_BATTLES = {
		0: [
			[SLIME],
		],
		1: [
			[MUSHROOM],
			[SKULL, SKULL]
		],
		2: [
			[ROOT, ZOMBIE, ZOMBIE],
		],
		3: [
			[ROOT, SKELETON, SKELETON]
		]
}

const BASE_CARDS = [
	preload("res://scenes/cards/ArmorCard.tscn"),
	preload("res://scenes/cards/MolotovCard.tscn"),
	preload("res://scenes/cards/DaggerCard.tscn")
]
const UPGRADED_CARDS = [
	preload("res://scenes/cards/SwordUpCard.tscn"),
	preload("res://scenes/cards/StaffUpCard.tscn"),
	preload("res://scenes/cards/ArmorUpCard.tscn"),
	preload("res://scenes/cards/MolotovUpCard.tscn"),
	preload("res://scenes/cards/DaggerUpCard.tscn")
]

var marked = []
@onready var progression_graph = {
	$"Map/1": [$"Map/2"],
	$"Map/2": [$"Map/3", $"Map/4"],
	$"Map/3": [$"Map/7"],
	$"Map/4": [$"Map/5"],
	$"Map/5": [$"Map/6"],
	$"Map/6": [$"Map/9"],
	$"Map/7": [$"Map/8"],
	$"Map/8": [$"Map/9"],
	$"Map/9": [$"Map/10", $"Map/11"],
	$"Map/10": [$"Map/12"],
	$"Map/11": [$"Map/12"]
}
@onready var current_position: MapIcon
@onready var INITIAL_CARDS = [load("res://scenes/cards/StaffCard.tscn"), load("res://scenes/cards/SwordCard.tscn")]
const CARD_QUANTITIES = [4, 6]

@onready var battle_container = $BattleHolder
@onready var card_reward = $CardReward
@onready var campfire = $Campfire

var deck = []
var playing = true
var difficulty_level = 0
var player_life = null


func fisher_yates_shuffle(l):
	var n = len(l)
	
	for i in range(n - 1):
		var j = randi() % (n - i) + i
		var aux = l[j]
		l[j] = l[i]
		l[i] = aux


func _ready():
	randomize()
	SoundController.play_music("Game")
	
	build_map()
	initialize_deck()
	
	for icon in progression_graph:
		icon.pressed.connect(clicked_icon.bind(icon))
	$"Map/12".pressed.connect(clicked_icon.bind($"Map/12"))


func _physics_process(delta):
	if Input.is_action_just_pressed("menu"):
		SceneManager.goto_scene("res://scenes/Menu.tscn")


func build_map():
	$"Map/1".set_mode(MapIcon.MODE.MARKER)
	$"Map/1".set_type(MapIcon.TYPE.BATTLE)
	$"Map/2".set_type(MapIcon.TYPE.CAMPFIRE)
	
	var routes = [[$"Map/3", $"Map/7", $"Map/8"], [$"Map/4", $"Map/5", $"Map/6"]]
	var types = [[MapIcon.TYPE.CAMPFIRE, MapIcon.TYPE.BATTLE, MapIcon.TYPE.BATTLE], [MapIcon.TYPE.CAMPFIRE, MapIcon.TYPE.BATTLE, MapIcon.TYPE.HARD_BATTLE]]
	
	fisher_yates_shuffle(routes)
	for type in types:
		fisher_yates_shuffle(type)
	
	for i in range(len(routes)):
		for j in range(len(routes[i])):
			routes[i][j].set_type(types[i][j])
	
	$"Map/9".set_type(MapIcon.TYPE.CAMPFIRE)
	if randi() % 2 == 0:
		$"Map/10".set_type(MapIcon.TYPE.HARD_BATTLE)
		$"Map/11".set_type(MapIcon.TYPE.BATTLE)
	else:
		$"Map/10".set_type(MapIcon.TYPE.BATTLE)
		$"Map/11".set_type(MapIcon.TYPE.HARD_BATTLE)
	
	$"Map/12".set_type(MapIcon.TYPE.BOSS)


func initialize_deck():
	deck = []
	for i in range(len(INITIAL_CARDS)):
		for j in range(CARD_QUANTITIES[i]):
			deck.append(INITIAL_CARDS[i].instantiate())


func upgrade_card(card):
	if card.upgrade_card == null:
		return
	
	deck.erase(card)
	var upgraded_card = card.upgrade_card.instantiate()
	deck.append(upgraded_card)
	card.queue_free()


func get_upgradable_cards(amount: int):
	var upgradable_cards = []
	for card in deck:
		if card.upgrade_card != null:
			upgradable_cards.append(card)
	
	fisher_yates_shuffle(upgradable_cards)
	return upgradable_cards.slice(0, amount)


func clicked_icon(icon):
	if icon.mode == MapIcon.MODE.MARKER and playing:
		playing = false
		if await process_icon(icon):
			return
		playing = true
		
		if current_position != null:
			current_position.set_mode(MapIcon.MODE.X)
		
		for i in marked:
			if i != icon:
				i.set_mode(MapIcon.MODE.X) 
		
		current_position = icon
		current_position.set_mode(MapIcon.MODE.ARROW)
		
		marked = []
		if current_position in progression_graph:
			for i in progression_graph[current_position]:
				i.set_mode(MapIcon.MODE.MARKER)
				marked.append(i)

## Processes an icon. Returns true if game ended
func process_icon(icon: MapIcon):
	match icon.type:
		MapIcon.TYPE.BATTLE:
			SoundController.play_sfx("EasyBattle")
			var pool = get_possible_battles(BATTLES)
			var battle: Battle = BATTLE.instantiate()
			battle_container.add_child(battle)
			if player_life != null:
				battle.initialize(pool[randi() % len(pool)], deck, player_life)
			else:
				battle.initialize(pool[randi() % len(pool)], deck)
			GlobalCamera.follow_pos(Vector2(240, -135))
			
			var result = await battle.battle()
			if result[0]:
				player_life = result[1]
				var card_reward = await card_reward.offer_reward(false)
				for card in card_reward:
					deck.append(card)
				
				GlobalCamera.follow_pos(Vector2(240, 135))
				difficulty_level += 1
				battle.queue_free()
			else:
				SceneManager.goto_scene("res://scenes/Lose.tscn")
		MapIcon.TYPE.HARD_BATTLE:
			SoundController.play_sfx("HardBattle")
			var pool = get_possible_battles(HARD_BATTLES)
			var battle: Battle = BATTLE.instantiate()
			battle_container.add_child(battle)
			if player_life != null:
				battle.initialize(pool[randi() % len(pool)], deck, player_life)
			else:
				battle.initialize(pool[randi() % len(pool)], deck)
			GlobalCamera.follow_pos(Vector2(240, -135))
			
			var result = await battle.battle()
			if result[0]:
				player_life = result[1]
				var card_reward = await card_reward.offer_reward(true)
				for card in card_reward:
					deck.append(card)
				
				GlobalCamera.follow_pos(Vector2(240, 135))
				difficulty_level += 1
				battle.queue_free()
			else:
				SceneManager.goto_scene("res://scenes/Lose.tscn")
		MapIcon.TYPE.CAMPFIRE:
			SoundController.play_sfx("UICampfire")
			GlobalCamera.follow_pos(Vector2(240, 405))
			await campfire.campfire()
			GlobalCamera.follow_pos(Vector2(240, 135))
		MapIcon.TYPE.BOSS:
			SoundController.play_sfx("UIBossBattle")
			var battle: Battle = BATTLE.instantiate()
			battle_container.add_child(battle)
			if player_life != null:
				battle.initialize([ROOT, NECRO, ROOT], deck, player_life)
			else:
				battle.initialize([ROOT, NECRO, ROOT], deck)
			GlobalCamera.follow_pos(Vector2(240, -135))
			
			var result = await battle.battle()
			if result[0]:
				SceneManager.goto_scene("res://scenes/Win.tscn")
			else:
				SceneManager.goto_scene("res://scenes/Lose.tscn")


func get_possible_battles(dict):
	var max = 0
	for i in dict:
		if i > max and i <= difficulty_level:
			max = i
	
	return dict[max]


func space_elements(elements: Array, aim_visual_counter: float, visual_counter: float, total_spacing: float):
	if visual_counter < 1:
		visual_counter = 1
	
	var spacing = total_spacing / (visual_counter + 1)
	var start = -total_spacing / 2
	for element in elements:
		start += spacing
		element.position[0] = start
	
	return lerp(visual_counter, aim_visual_counter, LERP_WEIGHT)
