extends RefCounted


const utils = preload("res://addons/expand-region/utils.gd")
var expand_to_regex_set = preload("res://addons/expand-region/expanders/expand_to_regex_set.gd").new()


func expand_to_subword(string: String, start, end):
	# if it is an upper case word search for upper case chars
	# else search for lower case chars
	var regex
	if(_is_inside_upper(string, start, end)):
		regex = RegEx.create_from_string("[A-Z]")
	else:
		regex = RegEx.create_from_string("[a-z]")

	var result = expand_to_regex_set._expand_to_regex_rule(
		string, start, end, regex, "subword")
	if result == null:
		return null
	# check if it is prefixed by an upper char
	# expand from camelC|ase| to camel|Case|
	var upper = RegEx.create_from_string("[A-Z]")
	if upper.search(string.substr(result["start"] - 1, 1)):
		result["start"] -= 1
	# check that it is a "true" subword, i.e. inside a word
	if not _is_true_subword(string, result):
		return null
	return result


func _is_true_subword(string: String, result):
	var start = result["start"]
	var end = result["end"]
	var char_before = string.substr(start-1, 1)
	var char_after = string.substr(end, 1)
	var is_word_before = search("[a-z0-9_]", char_before.to_lower())
	var is_word_after = search("[a-z0-9_]", char_after.to_lower())
	return is_word_before or is_word_after


func _is_inside_upper(string, start, end):
	var sub_str = string.substr(start, end - start)
	if start != end:
#		return string[start:end].isupper()
		return search("[A-Z]", sub_str) != null
#		return sub_str.to_upper() == sub_str
	start = max(0, start-2)
	end = min(end + 2, len(string))
	sub_str = string.substr(start, end - start)
	var contains_upper = search("[A-Z]{2}", sub_str)
#	sub_str = sub_str[1:3]
	sub_str = sub_str.substr(1, 2)
	var contains_lower = search("[a-z]", sub_str)
	return contains_upper and not contains_lower


func search(pattern, str):
	return RegEx.create_from_string(pattern).search(str)
