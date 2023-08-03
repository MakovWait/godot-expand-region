extends RefCounted

const utils = preload("res://addons/expand-region/utils.gd")

func expand_to_quotes(string, selection_start, selection_end):
	var quotes_regex = RegEx.new()
	quotes_regex.compile("(['\"])(?:\\.|.)*?\\1")
	
	# iterate over all found quotes pairs
	for rmatch in quotes_regex.search_all(string):
		var quotes_start = rmatch.get_start()
		var quotes_end = rmatch.get_end()
		
		# quotes pair end is before selection, stop here and continue loop
		if quotes_end < selection_start:
			continue

		# quotes pair start is after selection, return, no need to continue loop
		if quotes_start > selection_end:
			return null
		
		# quotes are already selection_end
		if(selection_start == quotes_start and selection_end == quotes_end):
			return null

		# the string w/o the quotes, "quotes content"
		var quotes_content_start = quotes_start + 1
		var quotes_content_end = quotes_end - 1

		# "quotes content" is selected, return with quotes
		if(selection_start == quotes_content_start and selection_end == quotes_content_end):
			return utils.create_return_obj(quotes_start, quotes_end, string, "quotes")

		# selection is within the found quote pairs, return "quotes content"
		if(selection_start > quotes_start and selection_end < quotes_end):
			return utils.create_return_obj(quotes_content_start, quotes_content_end, string, "quotes")
