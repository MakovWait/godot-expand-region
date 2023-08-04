extends RefCounted

const utils = preload("res://addons/expand-region/utils.gd")


func expand_to_line(string, startIndex, endIndex):
	var linebreakRe = RegEx.create_from_string('\n')

	var spacesAndTabsRe = RegEx.create_from_string('([ \t]+)')

	var searchIndex = startIndex - 1;
	var newStartIndex
	var newEndIndex
	while true:
		if searchIndex < 0:
			newStartIndex = searchIndex + 1
			break
		var char = utils.pysubstr(string, searchIndex, searchIndex + 1)
		if linebreakRe.search(char):
			newStartIndex = searchIndex + 1
			break
		else:
			searchIndex -= 1

	searchIndex = endIndex;
	while true:
		if searchIndex > len(string) - 1:
			newEndIndex = searchIndex
			break
		var char = utils.pysubstr(string, searchIndex, searchIndex + 1)
		if linebreakRe.search(char):
			newEndIndex = searchIndex
			break
		else:
			searchIndex += 1

	var s = utils.pysubstr(string, newStartIndex, newEndIndex)
	var r = spacesAndTabsRe.search(s)
	if r and r.get_end() <= startIndex:
		newStartIndex = newStartIndex + r.get_end();

	if startIndex == newStartIndex and endIndex == newEndIndex:
		return null
	else:
		return utils.create_return_obj(newStartIndex, newEndIndex, string, "line")
