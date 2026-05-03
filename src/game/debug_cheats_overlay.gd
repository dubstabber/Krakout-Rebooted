extends Control
class_name KrakoutDebugCheatsOverlay

signal add_bonus_requested(type_id: int)
signal remove_stack_entry_requested(index: int)
signal clear_stack_requested
signal close_requested

const GameSessionScript := preload("res://src/gameplay/krakout_game_session.gd")

const BASELINE_SIZE := Vector2(640, 480)
const WINDOW_POSITION := Vector2(38, 34)
const WINDOW_SIZE := Vector2(564, 412)
const CATALOG_WIDTH := 344.0
const STACK_WIDTH := 178.0

var _session
var _catalog_list: VBoxContainer
var _stack_list: VBoxContainer
var _stack_count_label: Label
var _status_label: Label
var _clear_button: Button


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = BASELINE_SIZE
	visible = false
	_build_layout()
	refresh()


func set_session(session) -> void:
	_session = session
	refresh()


func open() -> void:
	visible = true
	refresh()


func close() -> void:
	visible = false


func is_debug_visible() -> bool:
	return visible


func refresh(status_text := "") -> void:
	if _catalog_list == null or _stack_list == null:
		return

	_clear_children(_catalog_list)
	_clear_children(_stack_list)

	var entries := _bonus_stack_entries()
	var is_full := entries.size() >= GameSessionScript.MAX_STACKED_BONUSES
	for type_id in range(GameSessionScript.BONUS_TYPE_COUNT):
		_catalog_list.add_child(_make_bonus_catalog_row(type_id, is_full))

	if entries.is_empty():
		var empty_label := Label.new()
		empty_label.name = "EmptyStackLabel"
		empty_label.text = "Empty"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_color_override("font_color", Color(0.78, 0.82, 0.92))
		_stack_list.add_child(empty_label)
	else:
		for index in range(entries.size()):
			_stack_list.add_child(_make_stack_entry_row(index, entries[index]))

	if _stack_count_label != null:
		_stack_count_label.text = "Stack %d/%d" % [entries.size(), GameSessionScript.MAX_STACKED_BONUSES]
	if _status_label != null:
		_status_label.text = status_text
	if _clear_button != null:
		_clear_button.disabled = entries.is_empty()


func _build_layout() -> void:
	var backdrop := ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.position = Vector2.ZERO
	backdrop.size = BASELINE_SIZE
	backdrop.color = Color(0.0, 0.0, 0.0, 0.46)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)

	var panel := PanelContainer.new()
	panel.name = "DebugCheatsWindow"
	panel.position = WINDOW_POSITION
	panel.size = WINDOW_SIZE
	add_child(panel)

	var root := VBoxContainer.new()
	root.name = "WindowContent"
	root.add_theme_constant_override("separation", 8)
	panel.add_child(root)

	var header := HBoxContainer.new()
	header.name = "Header"
	root.add_child(header)

	var title := Label.new()
	title.name = "Title"
	title.text = "Debug Cheats"
	title.add_theme_font_size_override("font_size", 20)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_button := Button.new()
	close_button.name = "CloseButton"
	close_button.text = "Close"
	close_button.pressed.connect(func() -> void:
		close_requested.emit()
	)
	header.add_child(close_button)

	var body := HBoxContainer.new()
	body.name = "Body"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	root.add_child(body)

	body.add_child(_make_section("All Items", CATALOG_WIDTH, true))
	body.add_child(_make_section("Stack", STACK_WIDTH, false))

	var footer := HBoxContainer.new()
	footer.name = "Footer"
	footer.add_theme_constant_override("separation", 8)
	root.add_child(footer)

	_stack_count_label = Label.new()
	_stack_count_label.name = "StackCount"
	_stack_count_label.custom_minimum_size = Vector2(100, 24)
	_stack_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(_stack_count_label)

	_status_label = Label.new()
	_status_label.name = "Status"
	_status_label.clip_text = true
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.add_theme_color_override("font_color", Color(0.78, 0.88, 1.0))
	footer.add_child(_status_label)

	_clear_button = Button.new()
	_clear_button.name = "ClearStackButton"
	_clear_button.text = "Clear Stack"
	_clear_button.pressed.connect(func() -> void:
		clear_stack_requested.emit()
	)
	footer.add_child(_clear_button)


func _make_section(title_text: String, width: float, is_catalog: bool) -> PanelContainer:
	var section := PanelContainer.new()
	section.name = "%sSection" % title_text.replace(" ", "")
	section.custom_minimum_size = Vector2(width, 318)
	section.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var section_root := VBoxContainer.new()
	section_root.name = "SectionContent"
	section_root.add_theme_constant_override("separation", 4)
	section.add_child(section_root)

	var title := Label.new()
	title.name = "SectionTitle"
	title.text = title_text
	title.add_theme_font_size_override("font_size", 15)
	section_root.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	section_root.add_child(scroll)

	var list := VBoxContainer.new()
	list.name = "List"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 2)
	scroll.add_child(list)

	if is_catalog:
		_catalog_list = list
	else:
		_stack_list = list

	return section


func _make_bonus_catalog_row(type_id: int, is_full: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "BonusType%dRow" % type_id
	row.add_theme_constant_override("separation", 4)

	var label := Label.new()
	label.name = "BonusType%dLabel" % type_id
	label.text = "%02d  %s%s" % [type_id, GameSessionScript.bonus_type_name(type_id), _unsupported_suffix(type_id)]
	label.clip_text = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)

	var add_button := Button.new()
	add_button.name = "AddBonus%d" % type_id
	add_button.text = "Add"
	add_button.disabled = is_full
	add_button.custom_minimum_size = Vector2(48, 24)
	add_button.pressed.connect(func() -> void:
		add_bonus_requested.emit(type_id)
	)
	row.add_child(add_button)

	return row


func _make_stack_entry_row(index: int, entry: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "StackEntry%dRow" % index
	row.add_theme_constant_override("separation", 4)

	var type_id := int(entry.get("type_id", -1))
	var label := Label.new()
	label.name = "StackEntry%dLabel" % index
	label.text = "%02d  %s" % [index + 1, GameSessionScript.bonus_type_name(type_id)]
	label.clip_text = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)

	var remove_button := Button.new()
	remove_button.name = "RemoveStackEntry%d" % index
	remove_button.text = "Remove"
	remove_button.custom_minimum_size = Vector2(66, 24)
	remove_button.pressed.connect(func() -> void:
		remove_stack_entry_requested.emit(index)
	)
	row.add_child(remove_button)

	return row


func _bonus_stack_entries() -> Array[Dictionary]:
	if _session == null or not _session.has_method("bonus_stack_entries"):
		return []
	var entries: Array[Dictionary] = []
	for entry: Dictionary in _session.call("bonus_stack_entries"):
		entries.append(entry)
	return entries


func _unsupported_suffix(type_id: int) -> String:
	if GameSessionScript.SUPPORTED_BONUS_EFFECTS.has(type_id):
		return ""
	return "  unsupported"


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
