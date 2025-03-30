@tool
extends EditorPlugin

const SETTINGS_EXPAND_REGION = "addons/ExpandRegion/expand-region-shortcut"
const SETTINGS_SHRINK_REGION = "addons/ExpandRegion/shrink-region-shortcut"
const SETTINGS_LOGGING = "addons/ExpandRegion/print-logs"

var gdscript = preload("res://addons/expand-region/expanders/gdscript.gd").new()

var _history = History.new()
var _editor_settings: EditorSettings
var _expand_sh: Shortcut
var _shrink_sh: Shortcut
var _logging = false


func _enter_tree() -> void:
	_editor_settings = get_editor_interface().get_editor_settings()
	_update_editor_settings()
	_reload_settings()
	_editor_settings.settings_changed.connect(_on_editor_settings_changed)


func _exit_tree() -> void:
	_editor_settings.settings_changed.disconnect(_on_editor_settings_changed)


func _on_editor_settings_changed():
	_reload_settings()


func _expand():
	var code_edit = _get_current_code_edit()
	var edited_path = _get_edited_script_path()
	if not code_edit or not code_edit.has_focus() or edited_path == null:
		return
	var history_item = []
	for caret in code_edit.get_caret_count():
		var cursor: Cursor = Cursor.from_text_edit(code_edit, caret)
		var flat = cursor.to_flat(code_edit.text)
		var result = gdscript.expand(
			flat.string, flat.start, flat.end
		)
		if result:
			history_item.push_back({
				'idx': caret, 
				'start': flat.start,
				'end': flat.end,
				'new_start': result.start,
				'new_end': result.end
			})
			if _logging:
				print('{"type:": "%s", "expand_stack": "%s"}' % [result.get("type", "unknown"), result.get("expand_stack", [])])
			Cursor.from_flat(
				code_edit.text, result.start, result.end
			).select(code_edit, caret)
	_history.push(edited_path, history_item)
	code_edit.merge_overlapping_carets()


func _shrink():
	var edited_path = _get_edited_script_path()
	var code_edit = _get_current_code_edit()
	if code_edit and edited_path != null:
		_history.pop(edited_path, code_edit)


func _shortcut_input(event: InputEvent) -> void:
	if _expand_sh and _expand_sh.matches_event(event) and event.pressed:
		_expand()
	if _shrink_sh and _shrink_sh.matches_event(event) and event.pressed:
		_shrink()


func _reload_settings():
	_expand_sh = _editor_settings.get_setting(SETTINGS_EXPAND_REGION)
	_shrink_sh = _editor_settings.get_setting(SETTINGS_SHRINK_REGION)
	_logging = _editor_settings.get_setting(SETTINGS_LOGGING)


func _update_editor_settings():
	_update_editor_settings_sh(SETTINGS_EXPAND_REGION, _default_expand_sh)
	_update_editor_settings_sh(SETTINGS_SHRINK_REGION, _default_shrink_sh)
	_update_editor_settings_logging(false)


func _update_editor_settings_sh(setting_name, default):
	var editor_settings = get_editor_interface().get_editor_settings()
	if not editor_settings.has_setting(setting_name):
		editor_settings.set_setting(setting_name, default.call())
	editor_settings.add_property_info({
		"name": setting_name,
		"type": TYPE_OBJECT,
	})


func _update_editor_settings_logging(default):
	var editor_settings = get_editor_interface().get_editor_settings()
	if not editor_settings.has_setting(SETTINGS_LOGGING):
		editor_settings.set_setting(SETTINGS_LOGGING, default)
	editor_settings.add_property_info({
		"name": SETTINGS_LOGGING,
		"type": TYPE_BOOL,
	})


func _default_expand_sh():
	var sh = Shortcut.new()
	var ev = InputEventKey.new()
	ev.device = -1
	if OS.has_feature("macos"):
		ev.ctrl_pressed = true
	else:
		ev.alt_pressed = true
	ev.keycode = 87
	sh.events = [ev]
	return sh


func _default_shrink_sh():
	var sh = Shortcut.new()
	var ev = InputEventKey.new()
	ev.device = -1
	if OS.has_feature("macos"):
		ev.ctrl_pressed = true
	else:
		ev.alt_pressed = true
	ev.shift_pressed = true
	ev.keycode = 87
	sh.events = [ev]
	return sh


func _get_current_code_edit() -> CodeEdit:
	var script_editor = get_editor_interface().get_script_editor()
	if script_editor:
		script_editor = script_editor.get_current_editor()
		if script_editor:
			script_editor = script_editor.get_base_editor()
			return script_editor as CodeEdit
	return null


func _get_edited_script_path():
	var script_editor = get_editor_interface().get_script_editor()
	if script_editor:
		var current_editor = script_editor.get_current_editor()
		if current_editor:
			return current_editor.get("metadata/_tab_name")
	return null


class History:
	var _history_by_script = {}
	var _last_script_pathes = []
	
	func push(script_path: String, item):
		_update_last_script(script_path)
		_clear_old_scripts()
		var script_history = _get_script_history(script_path)
		script_history.push_front(item)
		if len(script_history) > 10:
			script_history.resize(10)
	
	func pop(script_path: String, code_edit: CodeEdit):
		var script_history = _get_script_history(script_path)
		if len(script_history) > 0:
			var carets = script_history.pop_front()
			for caret in carets:
				if caret.idx < code_edit.get_caret_count():
					var current_cursor = Cursor.from_text_edit(code_edit, caret.idx)
					var current_flat = current_cursor.to_flat(code_edit.text)
					if current_flat.start != caret.new_start or current_flat.end != caret.new_end:
						continue
					Cursor.from_flat(
						code_edit.text, caret.start, caret.end
					).select(code_edit, caret.idx)
	
	func _clear_old_scripts():
		for key in _history_by_script.keys().duplicate():
			if not key in _last_script_pathes:
				_history_by_script.erase(key)
	
	func _update_last_script(script_path):
		_last_script_pathes.erase(script_path)
		_last_script_pathes.push_front(script_path)
		if len(_last_script_pathes) > 5:
			_last_script_pathes.resize(5)
	
	func _get_script_history(script_path) -> Array:
		if not script_path in _history_by_script:
			_history_by_script[script_path] = []
		return _history_by_script[script_path]

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
		if text_edit.has_selection(caret_index):
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
