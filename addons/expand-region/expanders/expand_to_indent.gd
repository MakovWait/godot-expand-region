extends RefCounted

#_INDENT_RE = re.compile(r"^(?P<spaces>\s*)")

var _INDENT_RE = RegEx.create_from_string("^(?P<spaces>\\s*)")

const utils = preload("res://addons/expand-region/utils.gd")


func comment_line(string, line):
	var trimmed = utils.pysubstr(string, line["start"], line["end"]).strip_edges()
	return trimmed.begins_with("#")


func empty_line(string, line):
	var trimmed = utils.pysubstr(string, line["start"], line["end"]).strip_edges()
#	return not string[line["start"]:line["end"]].strip()
	return trimmed.is_empty()


func get_indent(string, line):
	var line_str = utils.pysubstr(string, line["start"], line["end"])
	var m = _INDENT_RE.search(line_str)
	if m == null:  # should never happen
		return 0
	return len(m.get_string("spaces"))


func _expand_to_indent(string, start, end):
	var line = utils.get_line(string, start, end)
	var indent = get_indent(string, line)
	start = line["start"]
	end = line["end"]
	var before_line = line
	while true:
		# get the line before
		var pos = before_line["start"] - 1
		if pos <= 0:
			break
		before_line = utils.get_line(string, pos, pos)
		var before_indent = get_indent(string, before_line)
		# done if the line has a lower indent
		if not indent <= before_indent and not empty_line(string, before_line) and not comment_line(string, before_line):
			break
		# if the indent equals the lines indent than update the start
		if not empty_line(string, before_line) and indent == before_indent:
			start = before_line["start"]

	var after_line = line
	while true:
		# get the line after
		var pos = after_line["end"] + 1
		if pos >= len(string):
			break
		after_line = utils.get_line(string, pos, pos)
		var after_indent = get_indent(string, after_line)
		# done if the line has a lower indent
		if not indent <= after_indent and not empty_line(string, after_line) and not comment_line(string, after_line):
			break
		# move the end
		if not empty_line(string, after_line):
			end = after_line["end"]

	return utils.create_return_obj(start, end, string, "indent")


func expand_to_indent(string, start, end):
	var result = _expand_to_indent(string, start, end)
	if result["start"] == start and result["end"] == end:
		return null
	return result


func py_expand_to_indent(string, start, end):
	var line = utils.get_line(string, start, end)
	var indent = get_indent(string, line)
	# we don't expand to indent 0 (whole document)
	if indent == 0:
		return null
	# expand to indent
	var result = _expand_to_indent(string, start, end)
	if result == null:
		return null
	# get the intent of the first lin
	# if the expansion changed return the result increased
	if not(result["start"] == start and result["end"] == end):
		return result
	var pos = result["start"] - 1
	while true:
		if pos < 0:
			return null
		# get the indent of the line before
		var before_line = utils.get_line(string, pos, pos)
		var before_indent = get_indent(string, before_line)
		if not empty_line(string, before_line) and before_indent < indent:
			start = before_line["start"]
			end = result["end"]
			return utils.create_return_obj(start, end, string, "py_indent")
		# goto the line before the line befor
		pos = before_line["start"] - 1
