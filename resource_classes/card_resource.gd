class_name CardResource
extends Resource

enum Trigger {
	ON_DRAW = 0,
	ON_DISCARD = 1,
	ON_CLICK = 2,
	WHILE = 3
}

var tags: Array[String] = []
@export var effects: Array[EffectResource] = []
@export var trigger: Trigger = Trigger.ON_DRAW

var source_deck_id: String = ""
var card_id: String = ""
var target_desc: String = ""

@export var card_name: String = ""
@export var icon: Texture2D
@export var effect_description: String = "Does a thing"


static func target_label(t: EffectResource.Target) -> String:
	match t:
		EffectResource.Target.SELF: return "This Card"
		EffectResource.Target.PLAYER: return "Yourself"
		EffectResource.Target.QUEUE_POS: return "Card Positions"
		EffectResource.Target.QUEUE_GROUP: return "Card Group"
#		EffectResource.Target.ENCOUNTER: return "An Enemy"
		_: return "no_target"

static func trigger_label(t: Trigger) -> String:
	match t:
		Trigger.ON_DRAW: return "Draw"
		Trigger.ON_DISCARD: return "Discard"
		Trigger.ON_CLICK: return "Click"
		Trigger.WHILE: return "While"
		_: return "no_trigger"
