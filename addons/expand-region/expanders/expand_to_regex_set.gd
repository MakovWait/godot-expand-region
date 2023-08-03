extends Node

const utils = preload("res://addons/expand-region/utils.gd")


func _expand_to_regex_rule(string, startIndex, endIndex, regex: RegEx, type):
	# if there is a selection (and not only a blinking cursor)
	if(startIndex != endIndex):
		var selection = utils.pysubstr(string, startIndex, endIndex)
		# make sure, that every character of the selection meets the regex rules,
		# if not return here
		if len(regex.search_all(selection)) != len(selection):
			return null

	# look back
	var searchIndex = startIndex - 1
	var newStartIndex
	var newEndIndex
	while true:
		# begin of string is reached
		if searchIndex < 0:
			newStartIndex = searchIndex + 1
			break
		var char = utils.pysubstr(string, searchIndex, searchIndex+1)
		# character found, that does not fit into the search set
		if regex.search(char) == null:
			newStartIndex = searchIndex + 1
			break
		else:
			searchIndex -= 1

	# look forward
	searchIndex = endIndex;
	while true:
		# end of string reached
		if searchIndex > len(string) - 1:
			newEndIndex = searchIndex
			break
		var char = utils.pysubstr(string, searchIndex, searchIndex+1)
		# character found, that does not fit into the search set
		if regex.search(char) == null:
			newEndIndex = searchIndex
			break
		else:
			searchIndex += 1

	if startIndex == newStartIndex and endIndex == newEndIndex:
		return null
	else:
		return utils.create_return_obj(newStartIndex, newEndIndex, string, type)
