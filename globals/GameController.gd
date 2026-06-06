extends Node

var deck_scene: PackedScene = preload("res://scenes/scene_components/deck/deck.tscn")
var current_decks: Dictionary[String, DeckResource] = {}

func unload_deck(deck_id: String) -> void:
	current_decks.erase(deck_id)
