extends MarginContainer
class_name QueueSlot

@onready var icon_rect = $Layout/BG

@export var drop_offset: Vector2 = Vector2(0, -300)
@export var duration: float = 0.55

var card: CardResource = null
var _active_tween: Tween = null


# flags
var is_clearing:bool = false

signal discard_request(card: CardResource)


func _ready() -> void:
	clear()

# queries
func is_empty() -> bool:
	return card == null and not is_clearing

# data methods
func assign(data: CardResource) -> void:
	if data == null:
		return
	card = data
	drop_in()
	_apply_icon(data.icon)

func clear() -> void:
	card = null
	if icon_rect: icon_rect.modulate.a = 0.0

func _apply_icon(texture: Texture2D) -> void:
	icon_rect.texture = texture
	icon_rect.modulate.a = 1.0

# handlers
func _on_button_pressed() -> void:
	if card == null:
		return
	discard_request.emit(card)
	clear()


# visuals
func drop_in() -> void:
	_kill_tween()
	icon_rect.position.y = drop_offset.y
	icon_rect.modulate.a = 1.0
	_active_tween = create_tween()
	_active_tween.set_ease(Tween.EASE_OUT)
	_active_tween.set_trans(Tween.TRANS_BOUNCE)
	_active_tween.tween_property(icon_rect, "position", Vector2.ZERO, duration)

func remove_out() -> Tween:
	_kill_tween()
	_active_tween = create_tween()
	_active_tween.set_ease(Tween.EASE_IN)
	_active_tween.set_trans(Tween.TRANS_BACK)
	_active_tween.set_parallel(true)
	_active_tween.tween_property(icon_rect, "position", Vector2(0, drop_offset.y * -1), duration * 0.6)
	_active_tween.tween_property(icon_rect, "modulate:a", 0.0, duration * 0.5)
	return _active_tween

func _kill_tween() -> void:
	if _active_tween and _active_tween.is_running():
		_active_tween.kill()
	_active_tween = null
