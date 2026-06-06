class_name CardQueue
extends MarginContainer

@onready var row1: Dictionary[String, QueueSlot] = {}
@onready var row2: Dictionary[String, QueueSlot] = {}
@onready var row3: Dictionary[String, QueueSlot] = {}
@onready var row4: Dictionary[String, QueueSlot] = {}
 
@onready var effects_queue:Array

signal queue_is_full
signal discard

func _ready() -> void:
	setup.emit


# queries
func open_slots() -> Array:
	return slots.filter(func(s): return s.is_empty())

func next_open_slot() -> Array:
	var next_slot = open_slots().front()
	var next_slot_number = next_slot.name.lstrip("Slot")
	var next_slot_button = get_node("VBoxContainer/ButtonQueue/Button" + next_slot_number)
	return [next_slot, next_slot_button]

func is_full() -> bool:
	return open_slots().is_empty()


# methods - take care, tracking card data in two places here, pull card data here later?
func add_card(card: CardResource) -> QueueSlot:
	if is_full():
		queue_is_full.emit()
		return
	var next = next_open_slot()
	var slot = next[0]
	var button = next[1]
	slot.button = button
	if slot:
		slot.assign(card)
		var target_str = ", ".join(card.effects.map(
			func(e): return CardResource.target_label(e.target)))
		button.update(target_str, CardResource.trigger_label(card.trigger), card.effect_description)
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.modulate.a = 1.0
	return slot

func remove_card(button:Button) -> void:
	var b = button.name.lstrip("Button")
	var s = get_node("VBoxContainer/CardQueue/Slot" + b)
	var card = s.card
	discard.emit(card)
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.modulate.a = 0.0
	s.is_clearing = true
	var tw = s.remove_out()
	tw.tween_callback(func():
		s.clear()
		s.is_clearing = false
		)

func lock_queue_slot(slot: QueueSlot) -> void:
	var b = slot.name.lstrip("Slot")
	var button = get_node("VBoxContainer/ButtonQueue/Button" + b)
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.modulate.a = 0.5

# handlers

func _on_queue_button_pressed(button) -> void:
	remove_card(button)
	print(button.name)
