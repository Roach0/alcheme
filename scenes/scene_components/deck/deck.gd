class_name Deck
extends AspectRatioContainer

@export var deck_data: DeckResource:
	set(value):
		deck_data = value
		if is_node_ready():
			build_deck()

@export var deck_id: String = ""

@onready var cards_count = $PanelContainer/MarginContainer/Panel/Draw
@onready var discards_count = $PanelContainer/MarginContainer/Panel/Discard

signal deck_empty
signal draw_request(deck: Deck)

var cards: Array[CardResource] = []
var discards: Array[CardResource] = []

func _ready() -> void:
	build_deck()

# queries
func is_empty() -> bool:
	return cards.is_empty()

# methods
func build_deck():
	if not deck_data:
		push_warning("Deck %s: no deck_data assigned" % deck_id)
		return
	cards.clear()
	discards.clear()
	for card in deck_data.cards:       # was deck_data.starting_cards
		cards.append(card.duplicate())
	cards.shuffle()
	_update_counts()

func draw_card() -> CardResource:
	if cards.is_empty():
		deck_empty.emit()
		return null
	var card = cards.pop_back()
	card.source_deck_id = deck_id
	_update_counts()
	return card

func discard(card: CardResource):
	discards.append(card)
	_update_counts()

func redraw():
	cards.append_array(discards)
	cards.shuffle()

# helpers
func _update_counts():
	cards_count.text = str(cards.size())
	discards_count.text = str(discards.size())

# handlers
func _on_button_pressed() -> void:
	draw_request.emit(self)
