extends RefCounted

const utils = preload("res://addons/expand-region/utils.gd")

var javascript = preload("res://addons/expand-region/expanders/javascript.gd").new()
var expand_to_indent = preload("res://addons/expand-region/expanders/expand_to_indent.gd").new()

func expand(string, start, end):
	var expand_stack = []
	var result = javascript.expand(string, start, end)
	if result:
		return result

	expand_stack.append("line_no_indent")
	result = expand_line_without_indent(string, start, end)
	if result:
		result["expand_stack"] = expand_stack
		return result

	expand_stack.append("line_continuation")
	result = expand_over_line_continuation(string, start, end)
	if result:
		return result

	expand_stack.append("py_block_start")
	result = expand_python_block_from_start(string, start, end)
	if result:
		result["expand_stack"] = expand_stack
		return result

	expand_stack.append("py_indent")
	result = expand_to_indent.py_expand_to_indent(string, start, end)
	if result:
		result["expand_stack"] = expand_stack
		return result


func expand_over_line_continuation(string, start, end):
	if not utils.pysubstr(string, end-1, end) == "\\":
		return null
	var line = utils.get_line(string, start, start)
	var next_line = utils.get_line(string, end + 1, end + 1)
	start = line["start"]
	end = next_line["end"]
	var next_result = expand_over_line_continuation(string, start, end)
	# recursive check if there is an other continuation
	if next_result:
		start = next_result["start"]
		end = next_result["end"]
	return utils.create_return_obj(start, end, string, "line_continuation")


func expand_python_block_from_start(string, start, end):
	if utils.pysubstr(string, end-1, end) != ":":
		return null
	var result = expand_to_indent.expand_to_indent(string, end + 1, end + 1)
	if result:
		# line = utils.get_line(string, start, start)
		var line = utils.get_line(string, start, start)
		start = line["start"]
		end = result["end"]
		return utils.create_return_obj(start, end, string, "py_block_start")


func expand_line_without_indent(string, start, end):
	var line = utils.get_line(string, start, end)
	var indent = expand_to_indent.get_indent(string, line)
	var lstart = min(start, line["start"] + indent)
	var lend = max(end, line["end"])
	if lstart != start or lend != end:
		return utils.create_return_obj(lstart, lend, string, "line_no_indent")
