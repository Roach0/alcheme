extends Node

@onready var queue: CardQueue
@onready var deck_container: Deck
@onready var effects: Effects

var deck_scene:Deck

func _ready():
	queue.discard.connect(_on_discard)
	player_panel_assembly(GameController.current_decks)
 
# queries
func is_queue_full() -> bool:
	if queue == null:
		push_warning("MissionManager: queue is null")
		return false
	return queue.is_full()


# scene builders
func player_panel_assembly(decks: Dictionary) -> void:
	for deck_id in decks:
		var d = deck_scene.instantiate()
		deck_container.add_child(d)
		d.deck_id = deck_id
		d.deck_data = decks[deck_id]
		d.draw_request.connect(_on_draw_request)


# handlers
func _on_draw_request(deck: Deck) -> void:
	if is_queue_full():
		return
	var card = deck.draw_card()
	if card == null:
		return

func _on_discard(card: CardResource) -> void:
	for child in deck_container.get_children():
		if child.deck_id == card.source_deck_id:
			child.discard(card)
			return
	push_warning("MissionManager: no deck found for source_deck_id '%s'" % card.source_deck_id)

func _on_action_button_pressed() -> void:
	pass # Replace with function body.


# methods
func remove_deck(deck_id: String) -> void:
	GameController.unload_deck(deck_id)
	for child in deck_container.get_children():
		if child.deck_id == deck_id:
			child.queue_free()
			break
