extends MarginContainer
class_name TileSlot

@onready var icon_rect = $Layout/BG
@export var drop_offset: Vector2 = Vector2(0, -300)
@export var duration: float = 0.55
var tile: TileResource = null
var button: Button = null
var _active_tween: Tween = null
var is_clearing: bool = false

func _ready() -> void:
	icon_rect.z_index = 1
	if tile == null:
		clear()

# --- Queries ---
func is_empty() -> bool:
	return tile == null and not is_clearing

# --- Data Methods ---
func assign(data: TileResource) -> void:
	print("assign() incoming script: ", data.get_script())
	if data == null:
		return
	tile = data.duplicate(true)
	# Restore the subclass script that duplicate() dropped
	if tile.get_script() != data.get_script():
		tile.set_script(data.get_script())
	if tile.has_method("_post_duplicate"):
		tile._post_duplicate()
	tile._randomize_icon()
	if not is_node_ready():
		await ready
	drop_in()
	_apply_icon(tile.get_icon())
	icon_rect.modulate.a = 1.0

func clear() -> void:
	tile = null
	if icon_rect:
		icon_rect.modulate.a = 0.0

func _apply_icon(texture: Texture2D) -> void:
	icon_rect.texture = texture
	icon_rect.modulate.a = 1.0

# --- Visuals ---
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

func update_hp_display(current: int, max_hp: int) -> void:
	var pct = float(current) / float(max_hp)
	icon_rect.modulate = Color(1.0, pct, pct, 1.0)  # reddens as HP falls
