static func create_return_obj(start, end, string, type):
	return {"start": start, "end": end, "string": string.substr(start, end - start), "type": type}


static func substr(string, selection):
	return pysubstr(string, selection.start, selection.end)


static func pysubstr(string, start, end):
	return string.substr(start, end - start)


static func escape(str: String):
	var special_chars = ["\\", ".", "*", "+", "?", "|", "(", ")", "[", "]", "{", "}", "^", "$"]
	var escaped_string = ""
	for char in str:
		if special_chars.find(char) != -1:
			escaped_string += "\\" + char
		else:
			escaped_string += char   
	return escaped_string

#	return RegEx.create_from_string(
#		"([.*+?^=!:${}()|\\[\\]\\/\\\\])"
#	).sub(str, "\\$1")


static func trim(string: String):
	var regStart = RegEx.create_from_string("^[ \t\n]*")
	var regEnd = RegEx.create_from_string("[ \t\n]*$")
	var rS = regStart.search(string)
	var rE = regEnd.search(string)
	var start = 0
	var end = len(string);
	if rS:
		start = len(rS.get_string())
	if rE:
		end = rE.get_start()
	if rS and rE:
		return {"start": start, "end": end}
	else:
		return null


static func selection_contain_linebreaks(string, s, e):
	return '\n' in string.substr(s, e - s)


static func is_escaped_linebreak(string, idx):
	var symbol = string.substr(idx, 1)
	var prev_symbol = string.substr(idx - 1, 1)
	return symbol == '\n' and prev_symbol == '\\'


static func get_line(string: String, startIndex, endIndex):
	var linebreakRe = RegEx.create_from_string('\n')

	var searchIndex = startIndex - 1
	var newStartIndex
	var newEndIndex
	while true:
		if searchIndex < 0:
			newStartIndex = searchIndex + 1
			break
		var char = string.substr(searchIndex, 1)
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
		var char = string.substr(searchIndex, 1)
		if linebreakRe.search(char):
			newEndIndex = searchIndex
			break
		else:
			searchIndex += 1

	return {"start": newStartIndex, "end": newEndIndex}
