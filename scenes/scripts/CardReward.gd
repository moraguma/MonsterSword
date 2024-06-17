extends Node2D

signal chose(cards)


const MAX_SPACING = 200

@onready var game: Game = get_parent()
var max_selection
var selection = []
var selected_cards = []
var can_select = false


@onready var explanation = $Label
@onready var select_card_error = $Select/SelectCard
@onready var xsort = $XSort

var can_interact = true


func campfire():
	selection = game.get_upgradable_cards(5)
	selected_cards = []
	
	explanation.text = "Select 1 card to upgrade"
	select_card_error.text = "Select 1 card"
	max_selection = 1
	
	for card in selection:
		xsort.add_child(card)
		card.update_battle_ref()
	game.space_elements(selection, len(selection), len(selection), MAX_SPACING)
	
	var result = await chose
	SoundController.play_sfx("Upgrade")
	
	for child in xsort.get_children():
		xsort.remove_child(child)
	
	for card in result:
		game.upgrade_card(card)


# Returns the cards selected
func offer_reward(upgraded: bool):
	show()
	selection = []
	selected_cards = []
	
	if upgraded:
		explanation.text = "Select up to 2 cards to add to your deck"
		select_card_error.text = "Select up to 2 cards"
		max_selection = 2
		
		for i in range(2):
			selection.append(game.UPGRADED_CARDS[randi() % len(game.UPGRADED_CARDS)].instantiate())
	else:
		explanation.text = "Select 1 card to add to your deck"
		select_card_error.text = "Select 1 card"
		max_selection = 1
	
	for i in range(3):
		selection.append(game.BASE_CARDS[randi() % len(game.BASE_CARDS)].instantiate())
	
	game.fisher_yates_shuffle(selection)
	
	for card in selection:
		xsort.add_child(card)
	game.space_elements(selection, len(selection), len(selection), MAX_SPACING)
	
	var result = await chose
	SoundController.play_sfx("Upgrade")
	
	for child in xsort.get_children():
		xsort.remove_child(child)
	for card in result:
		card.pressed()
	for card in selection:
		if not card in result:
			card.queue_free()
	
	hide()
	
	return result


func select_card(card):
	selected_cards.append(card)
	update_buttons()
	return true


func desselect_card(card):
	selected_cards.erase(card)
	update_buttons()


func update_buttons():
	if len(selected_cards) > 0 and len(selected_cards) <= max_selection:
		can_select = true
		select_card_error.hide()
	else:
		can_select = false
		select_card_error.show()


func selected():
	if can_select:
		chose.emit(selected_cards.duplicate())


func skip():
	chose.emit([])


