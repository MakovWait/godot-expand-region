@tool
extends EditorPlugin

const SETTINGS_EXPAND_REGION = "addons/ExpandRegion/expand-region-shortcut"
const SETTINGS_SHRINK_REGION = "addons/ExpandRegion/shrink-region-shortcut"

var gdscript = preload("res://addons/expand-region/expanders/gdscript.gd").new()

var _editor_settings: EditorSettings
var _expand_sh: Shortcut
var _shrink_sh: Shortcut


func _enter_tree() -> void:
	_editor_settings = get_editor_interface().get_editor_settings()
	_editor_settings.changed.connect(_on_editor_settings_changed)
	_update_editor_settings()
	_load_shortcuts()


func _exit_tree() -> void:
	_editor_settings.changed.disconnect(_on_editor_settings_changed)


func _on_editor_settings_changed():
	_load_shortcuts()


func _shortcut_input(event: InputEvent) -> void:
	if _expand_sh and _expand_sh.matches_event(event) and event.pressed:
		var code_edit = _get_current_code_edit()
#		if code_edit and code_edit.has_selection():
		var cursor: Cursor = Cursor.from_text_edit(code_edit)
		var flat = cursor.to_flat(code_edit.text)
		var result = gdscript.expand(
			flat.string, flat.start, flat.end
		)
		print(result)
		if result:
			Cursor.from_flat(code_edit.text, result.start, result.end).select(code_edit)
			


func _load_shortcuts():
	_expand_sh = _editor_settings.get_setting(SETTINGS_EXPAND_REGION)


func _update_editor_settings():
	var editor_settings = get_editor_interface().get_editor_settings()
	if not editor_settings.has_setting(SETTINGS_EXPAND_REGION):
		var sh = Shortcut.new()
		var ev = InputEventKey.new()
		ev.device = -1
		ev.shift_pressed = true
		ev.meta_pressed = true
		ev.keycode = 70
		sh.events = [ev]
		editor_settings.set_setting(SETTINGS_EXPAND_REGION, sh)
	editor_settings.add_property_info({
		"name": SETTINGS_EXPAND_REGION,
		"type": TYPE_OBJECT,
	})


func _get_current_code_edit() -> CodeEdit:
	var script_editor = get_editor_interface().get_script_editor()
	if script_editor:
		script_editor = script_editor.get_current_editor()
		if script_editor:
			script_editor = script_editor.get_base_editor()
			return script_editor as CodeEdit
	return null


class Cursor:
	var _from_line
	var _to_line
	var _from_col
	var _to_col
	
	func _init(from_line, to_line, from_col, to_col) -> void:
		self._from_line = from_line
		self._to_line = to_line
		self._from_col = from_col
		self._to_col = to_col
	
	func to_flat(text: String):
		var lines = text.split("\n")
		var start = 0
		var end = 0
		for line in range(_to_line):
			if line < _from_line:
				start += len(lines[line]) + 1
			end += len(lines[line]) + 1
		start += _from_col
		end += _to_col
		return {
			'string': text,
			'start': start,
			'end': end,
		}
	
	func select(text_edit: TextEdit, caret_index=0):
		text_edit.select(
			_from_line,
			_from_col,
			_to_line,
			_to_col,
			caret_index
		)
	
	static func from_text_edit(text_edit: TextEdit, caret_index=0) -> Cursor:
		if text_edit.has_selection():
			return Cursor.new(
			 	text_edit.get_selection_from_line(caret_index),
			 	text_edit.get_selection_to_line(caret_index),
			 	text_edit.get_selection_from_column(caret_index),
			 	text_edit.get_selection_to_column(caret_index),
			)
		else:
			return Cursor.new(
				text_edit.get_caret_line(caret_index),
				text_edit.get_caret_line(caret_index),
				text_edit.get_caret_column(caret_index),
				text_edit.get_caret_column(caret_index),
			)
	
	static func from_flat(text: String, start: int, end: int) -> Cursor:
		var from = _line_and_col_by_pos(text, start)
		var to = _line_and_col_by_pos(text, end)
		return Cursor.new(from.line, to.line, from.col, to.col)

	static func _line_and_col_by_pos(text: String, pos: int):
		var line = 0
		var col = 0
		for i in range(pos):
			if text[i] == '\n':
				line += 1
				col = 0
			else:
				col +=1
		return {
			'line': line,
			'col': col
		}
