extends RefCounted

const utils = preload("res://addons/expand-region/utils.gd")


func expand_to_semantic_unit(string, startIndex, endIndex):
#	return expand_to_semantic_unit_original(string, startIndex, endIndex)
	
	var result

	result = expand_to_semantic_method(string, startIndex, endIndex)
	if result:
		return result

	result = expand_to_semantic_owner(string, startIndex, endIndex)
	if result:
		return result

	result = expand_to_semantic_property(string, startIndex, endIndex)
	if result:
		return result
	
	result = expand_to_semantic_unit_original(string, startIndex, endIndex)
	if result:
		return result


func expand_to_semantic_unit_original(string, startIndex, endIndex):
	var symbols = "([{)]}"
	var breakSymbols = ",;=&|\n\r"
	var lookBackBreakSymbols = breakSymbols + "([{"
	var lookForwardBreakSymbols = breakSymbols + ")]}"
	var symbolsRe = RegEx.create_from_string(
		'(['+utils.escape(symbols)+utils.escape(breakSymbols)+'])'
	)

	var counterparts = {
		"(":")",
		"{":"}",
		"[":"]",
		")":"(",
		"}":"{",
		"]":"["
	}

	var symbolStack = []

	var searchIndex = startIndex - 1
	var newStartIndex
	var newEndIndex
	while true:
		if(searchIndex < 0):
			newStartIndex = searchIndex + 1
			break
		var char = string.substr(searchIndex, 1)
		var result = symbolsRe.search(char)
		if result:
			var symbol = result.get_string()

			if(symbol in lookBackBreakSymbols and len(symbolStack) == 0):
				newStartIndex = searchIndex + 1
				break

			if symbol in symbols:
				if len(symbolStack) > 0 and symbolStack[len(symbolStack) - 1] == counterparts[symbol]:
					symbolStack.pop_back()
				else:
					symbolStack.append(symbol)

		# print("ExpandRegion, expand_to_semantic_unit.py, " + char + " " + symbolStack)
		searchIndex -= 1
	
	
	for i in range(startIndex, endIndex):
		searchIndex = i
		var char = string.substr(searchIndex, 1)
		var result = symbolsRe.search(char)
		if result:
			var symbol = result.get_string()
			if symbol in symbols:
				if len(symbolStack) > 0 and symbolStack[len(symbolStack) - 1] == counterparts[symbol]:
					symbolStack.pop_back()
				else:
					symbolStack.append(symbol)
	
	searchIndex = endIndex
	while true:
		var char = string.substr(searchIndex, 1)
		var result = symbolsRe.search(char)
		if result:
			var symbol = result.get_string()

			if len(symbolStack) == 0 and symbol in lookForwardBreakSymbols:
				newEndIndex = searchIndex;
				break

			if symbol in symbols:
				if len(symbolStack) > 0 and symbolStack[len(symbolStack) - 1] == counterparts[symbol]:
					symbolStack.pop_back()
				else:
					symbolStack.append(symbol)

		if searchIndex >= len(string) - 1:
			return null

		# print("ExpandRegion, latex.py, " + char + " " + symbolStack + " " + searchIndex)
		searchIndex += 1

	var s = string.substr(newStartIndex, newEndIndex - newStartIndex)

	# print( utils )
	var trimResult = utils.trim(s)
	if trimResult:
		newStartIndex = newStartIndex + trimResult["start"];
		newEndIndex = newEndIndex - (len(s) - trimResult["end"]);

	if newStartIndex == startIndex and newEndIndex == endIndex:
		return null

	if newStartIndex > startIndex or newEndIndex < endIndex:
		return null

	return utils.create_return_obj(newStartIndex, newEndIndex, string, "semantic_unit")


func expand_to_semantic_owner(string, startIndex, endIndex):
	var symbols = "([{)]}"
	var breakSymbols = " ,;=&|\n\r"
	var lookBackBreakSymbols = breakSymbols + "([{"
	var lookForwardBreakSymbols = breakSymbols + ")]}"
	var symbolsRe = RegEx.create_from_string(
		'(['+utils.escape(symbols)+utils.escape(breakSymbols)+'])'
	)

	var counterparts = {
		"(":")",
		"{":"}",
		"[":"]",
		")":"(",
		"}":"{",
		"]":"["
	}
	
	var symbolStack = []
	
	var searchIndex = startIndex - 1
	var newStartIndex = startIndex
	var newEndIndex = endIndex
	while true:
		if(searchIndex < 0):
			newStartIndex = searchIndex + 1
			break
		var char = string.substr(searchIndex, 1)
		var result = symbolsRe.search(char)
		if result:
			var symbol = result.get_string()

			if(symbol in lookBackBreakSymbols and len(symbolStack) == 0):
				newStartIndex = searchIndex + 1
				break

			if symbol in symbols:
				if len(symbolStack) > 0 and symbolStack[len(symbolStack) - 1] == counterparts[symbol]:
					symbolStack.pop_back()
#					break
				else:
					symbolStack.append(symbol)

#		print("ExpandRegion, expand_to_semantic_unit2.py, " + str(char) + " " + str(symbolStack))
		searchIndex -= 1

	var s = string.substr(newStartIndex, newEndIndex - newStartIndex)
	# print( utils )
	var trimResult = utils.trim(s)
	if trimResult:
		newStartIndex = newStartIndex + trimResult["start"];
		newEndIndex = newEndIndex - (len(s) - trimResult["end"]);

	if newStartIndex == startIndex and newEndIndex == endIndex:
		return null

	if newStartIndex > startIndex or newEndIndex < endIndex:
		return null

	return utils.create_return_obj(newStartIndex, newEndIndex, string, "semantic_unit_owner")


func expand_to_semantic_method(string, startIndex, endIndex):
	var symbols = "([{)]}"
	var breakSymbols = ".#/:+ ,;=&|\n\r"
	var lookBackBreakSymbols = breakSymbols + "([{"
	var lookForwardBreakSymbols = breakSymbols + ")]}"
	var symbolsRe = RegEx.create_from_string(
		'(['+utils.escape(symbols)+utils.escape(breakSymbols)+'])'
	)

	var counterparts = {
		"(":")",
		"{":"}",
		"[":"]",
		")":"(",
		"}":"{",
		"]":"["
	}
	
	var symbolStack = []
	
	var searchIndex = startIndex
	var newStartIndex = startIndex
	var newEndIndex = endIndex
	searchIndex = endIndex;
	while true:
		var char = string.substr(searchIndex, 1)
		var result = symbolsRe.search(char)
		if result:
			var symbol = result.get_string()

			if(symbol in lookForwardBreakSymbols and len(symbolStack) == 0):
				newStartIndex = searchIndex + 1
				break
			
			if symbol in symbols:
				if len(symbolStack) > 0 and symbolStack[len(symbolStack) - 1] == counterparts[symbol]:
					symbolStack.pop_back()
					if len(symbolStack) == 0:
						newEndIndex = searchIndex + 1
						break
				elif symbol in "([{":
					symbolStack.append(symbol)

		if searchIndex >= len(string) - 1:
			return null

#		print("ExpandRegion, latex.py, " + char + " " + str(symbolStack) + " " + str(searchIndex))
		searchIndex += 1

	var s = string.substr(newStartIndex, newEndIndex - newStartIndex)
	if s in breakSymbols:
		return null
	# print( utils )
	var trimResult = utils.trim(s)
	if trimResult:
		newStartIndex = newStartIndex + trimResult["start"];
		newEndIndex = newEndIndex - (len(s) - trimResult["end"]);

	if newStartIndex == startIndex and newEndIndex == endIndex:
		return null

	if newStartIndex > startIndex or newEndIndex < endIndex:
		return null

	return utils.create_return_obj(newStartIndex, newEndIndex, string, "semantic_unit_method")


func expand_to_semantic_property(string, startIndex, endIndex):
	var symbols = "([{)]}"
	var breakSymbols = " ,;:=&|\n\r"
	var lookBackBreakSymbols = breakSymbols + "([{"
	var lookForwardBreakSymbols = breakSymbols + symbols
	var symbolsRe = RegEx.create_from_string(
		'(['+utils.escape(symbols)+utils.escape(breakSymbols)+'])'
	)

	var counterparts = {
		"(":")",
		"{":"}",
		"[":"]",
		")":"(",
		"}":"{",
		"]":"["
	}
	
	var symbolStack = []
	var dots = 0
	var searchIndex = startIndex - 1
	var newStartIndex = startIndex
	var newEndIndex = endIndex
	searchIndex = endIndex;
	while true:
		var char = string.substr(searchIndex, 1)
		if char == ".":
			dots += 1
		if dots == 2:
			newEndIndex = searchIndex;
			break
		var result = symbolsRe.search(char)
		if result:
			var symbol = result.get_string()
			
			if symbol in lookForwardBreakSymbols:
				newEndIndex = searchIndex;
				break

		if searchIndex >= len(string) - 1:
			return null

#		print("ExpandRegion, latex.py, " + char + " " + str(symbolStack) + " " + str(searchIndex))
		searchIndex += 1

	var s = string.substr(newStartIndex, newEndIndex - newStartIndex)
	# print( utils )
	var trimResult = utils.trim(s)
	if trimResult:
		newStartIndex = newStartIndex + trimResult["start"];
		newEndIndex = newEndIndex - (len(s) - trimResult["end"]);

	if newStartIndex == startIndex and newEndIndex == endIndex:
		return null

	if newStartIndex > startIndex or newEndIndex < endIndex:
		return null

	return utils.create_return_obj(newStartIndex, newEndIndex, string, "semantic_unit_property")
