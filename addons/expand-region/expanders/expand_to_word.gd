extends Node

var expand_to_regex_set = preload("res://addons/expand-region/expanders/expand_to_regex_set.gd").new()


func expand_to_word(string, startIndex, endIndex):
#	var regex = re.compile("[\w$]", re.UNICODE)
#	var regex = RegEx.create_from_string(
#		"[\\u00BF-\\u1FFF\\u2C00-\\uD7FF\\w$]"
#	)
	var regex = RegEx.create_from_string(
		"[\\w$]"
	)
	return expand_to_regex_set._expand_to_regex_rule(string, startIndex, endIndex, regex, "word")
