extends RefCounted

const utils = preload("res://addons/expand-region/utils.gd")

var expand_to_quotes = preload("res://addons/expand-region/expanders/expand_to_quotes.gd").new()
var expand_to_semantic_unit = preload("res://addons/expand-region/expanders/expand_to_semantic_unit.gd").new()
var expand_to_symbols = preload("res://addons/expand-region/expanders/expand_to_symbols.gd").new()
var expand_to_subword = preload("res://addons/expand-region/expanders/expand_to_subword.gd").new()
var expand_to_word = preload("res://addons/expand-region/expanders/expand_to_word.gd").new()
var expand_to_line = preload("res://addons/expand-region/expanders/expand_to_line.gd").new()


func expand(string, start, end):
	var selection_is_in_string = expand_to_quotes.expand_to_quotes(string, start, end)
	if selection_is_in_string:
		var string_result = expand_agains_string(selection_is_in_string["string"], start - selection_is_in_string["start"], end - selection_is_in_string["start"])
		
		if string_result:
			string_result["start"] = string_result["start"] + selection_is_in_string["start"]
			string_result["end"] = string_result["end"] + selection_is_in_string["start"]
			string_result["string"] = utils.substr(string, string_result)
			return string_result
	
	if not utils.selection_contain_linebreaks(string, start, end):
		var line = utils.get_line(string, start, end)
		var line_string = utils.substr(string, line)

		var line_result = expand_agains_line(line_string, start - line["start"], end - line["start"])

		if line_result:
			line_result["start"] = line_result["start"] + line["start"]
			line_result["end"] = line_result["end"] + line["start"]
			line_result["string"] = utils.substr(string, line_result)
			return line_result

	var expand_stack = ["semantic_unit"]

	var result = expand_to_semantic_unit.expand_to_semantic_unit(string, start, end)

	if result:
		result["expand_stack"] = expand_stack
		return result

	expand_stack.append("symbols")

	result = expand_to_symbols.expand_to_symbols(string, start, end)
	if result:
		result["expand_stack"] = expand_stack
		return result
	
#	expand_stack.append("line")
#
#	result = expand_to_line.expand_to_line(string, start, end)
#	if result:
#		result["expand_stack"] = expand_stack
#		return result
#
#	return null


func expand_agains_line(string, start, end):
	var expand_stack = []

	expand_stack.append("subword")

	var result = expand_to_subword.expand_to_subword(string, start, end)
	if result:
		result["expand_stack"] = expand_stack
		return result

	expand_stack.append("word")

	result = expand_to_word.expand_to_word(string, start, end)
	if result:
		result["expand_stack"] = expand_stack
		return result

	expand_stack.append("quotes")

	result = expand_to_quotes.expand_to_quotes(string, start, end)
	if result:
		result["expand_stack"] = expand_stack
		return result

	expand_stack.append("semantic_unit")

	result = expand_to_semantic_unit.expand_to_semantic_unit(string, start, end)
	if result:
		result["expand_stack"] = expand_stack
		return result

	expand_stack.append("symbols")

	result = expand_to_symbols.expand_to_symbols(string, start, end)
	if result:
		result["expand_stack"] = expand_stack
		return result

	# expand_stack.append("line")

	# result = expand_to_line.expand_to_line(string, start, end)
	# if result:
	#   result["expand_stack"] = expand_stack
	#   return result

	# return None


func expand_agains_string(string, start, end):
	var expand_stack = []

	expand_stack.append("semantic_unit")

	var result = expand_to_semantic_unit.expand_to_semantic_unit(string, start, end)
	if result:
		result["expand_stack"] = expand_stack
		return result

	expand_stack.append("symbols")

	result = expand_to_symbols.expand_to_symbols(string, start, end)
	if result:
		result["expand_stack"] = expand_stack
		return result
