extends RefCounted

const utils = preload("res://addons/expand-region/utils.gd")


func expand_to_symbols(string, selection_start, selection_end):
	var opening_symbols = "([{";
	var closing_symbols = ")]}";
	var symbols_regex = RegEx.create_from_string(
		"[" + utils.escape(opening_symbols + closing_symbols) + "]"
	)

	var quotes_regex = RegEx.create_from_string("(['\"])(?:\\1|.*?\\1)")
	var quotes_blacklist = {}
	
	# get all quoted strings and create dict with key of index = True
	# Example: f+"oob"+bar
	# quotes_blacklist = {
	#   2: true, 3: true, 4: true, 5: true, 6: true
	# }
	for rmatch in quotes_regex.search_all(string):
		var quotes_start = rmatch.get_start()
		var quotes_end = rmatch.get_end()
		var i = 0
		while true:
			quotes_blacklist[quotes_start + i] = true
			i += 1
			if (quotes_start + i == quotes_end):
				break

	var counterparts = {
		"(":")",
		"{":"}",
		"[":"]",
		")":"(",
		"}":"{",
		"]":"["
	}

	# find symbols in selection that are "not closed"
	var selection_string = string.substr(selection_start, selection_end - selection_start)
	var selection_quotes = symbols_regex.search_all(selection_string).map(
		func(x): return x.get_string()
	)

	var backward_symbols_stack = []
	var forward_symbols_stack = []

	if(len(selection_quotes) != 0):
		var inspect_index = 0
		# remove symbols that have a counterpart, i.e. that are "closed"
		while true:
			var item = selection_quotes[inspect_index]
			if(counterparts[item] in selection_quotes):
				selection_quotes.remove_at(selection_quotes.find(item))
				selection_quotes.remove_at(selection_quotes.find(counterparts[item]))
			else:
				inspect_index = inspect_index + 1
			if(inspect_index >= len(selection_quotes)):
				break;

		# put the remaining "open" symbols in the stack lists depending if they are
		# opening or closing symbols
		for item in selection_quotes:
			if(item in opening_symbols):
				forward_symbols_stack.append(item)
			elif(item in closing_symbols):
				backward_symbols_stack.append(item)

	var search_index = selection_start - 1
	var symbol
	var symbols_start
	# look back from begin of selection
	while true:
		# begin of string reached
		if(search_index < 0):
			return null

		# skip if current index is within a quote
		if (quotes_blacklist.get(search_index, false) == true):
			search_index -= 1
			continue
		var character = string.substr(search_index, 1)
		var result = symbols_regex.search(character)

		if result:
			symbol = result.get_string()

			# symbol is opening symbol and stack is empty, we found the symbol we want to expand to
			if(symbol in opening_symbols and len(backward_symbols_stack) == 0):
				symbols_start = search_index + 1
				break

			if len(backward_symbols_stack) > 0 and backward_symbols_stack[len(backward_symbols_stack) - 1] == counterparts[symbol]:
				# last symbol in the stack is the counterpart of the found one
				backward_symbols_stack.pop_back()
			else:
				backward_symbols_stack.append(symbol)

		search_index -= 1

	var symbol_pair_regex = RegEx.create_from_string("[" + utils.escape(symbol + counterparts[symbol]) + "]")

	forward_symbols_stack.append(symbol)

	search_index = selection_end
	var symbols_end
	# look forward from end of selection
	while true:
		# skip if current index is within a quote
		if (quotes_blacklist.get(search_index, false) == true):
			search_index += 1
			continue;
		var character = string.substr(search_index, 1)
		var result = symbol_pair_regex.search(character)

		if result:
			symbol = result.get_string()

			if forward_symbols_stack[len(forward_symbols_stack) - 1] == counterparts[symbol]:
				# counterpart of found symbol is the last one in stack, remove it
				forward_symbols_stack.pop_back()
			else:
				forward_symbols_stack.append(symbol)

			if len(forward_symbols_stack) == 0:
				symbols_end = search_index
				break

		# end of string reached
		if search_index == len(string):
			return

		search_index += 1

	if(selection_start == symbols_start and selection_end == symbols_end):
		return utils.create_return_obj(symbols_start - 1, symbols_end + 1, string, "symbol")
	else:
		return utils.create_return_obj(symbols_start, symbols_end, string, "symbol")
