extends GdUnitTestSuite


var javascript = preload("res://addons/expand-region/expanders/javascript.gd").new()


var string1
var string2
var string3
var string4


func before():
	string1 = FileAccess.open("res://tests/snippets/integration_01.txt", FileAccess.READ).get_as_text()
	string2 = FileAccess.open("res://tests/snippets/integration_02.txt", FileAccess.READ).get_as_text()
	string3 = FileAccess.open("res://tests/snippets/integration_03.txt", FileAccess.READ).get_as_text()
	string4 = FileAccess.open("res://tests/snippets/integration_04.txt", FileAccess.READ).get_as_text()


func test_subword():
	var result = javascript.expand(self.string1, 7, 7);
	self.assertEqual(result["start"], 6)
	self.assertEqual(result["end"], 9)
	self.assertEqual(result["string"], "bar")
	self.assertEqual(result["type"], "subword")
	self.assertEqual(result["expand_stack"], ["subword"])

func test_word():
	var result = javascript.expand(self.string1, 6, 9);
	self.assertEqual(result["start"], 2)
	self.assertEqual(result["end"], 9)
	self.assertEqual(result["string"], "foo_bar")
	self.assertEqual(result["type"], "word")
	self.assertEqual(result["expand_stack"], ["subword", "word"])

func test_quotes_inner():
	var result = javascript.expand(self.string1, 2, 9);
	self.assertEqual(result["start"], 2)
	self.assertEqual(result["end"], 17)
	self.assertEqual(result["string"], "foo_bar foo bar")
	self.assertEqual(result["type"], "quotes")
	self.assertEqual(result["expand_stack"], ["subword", "word", "quotes"])

func test_quotes_outer():
	var result = javascript.expand(self.string1, 2, 17);
	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 18)
	self.assertEqual(result["string"], "\"foo_bar foo bar\"")
	self.assertEqual(result["type"], "quotes")
	self.assertEqual(result["expand_stack"], ["subword", "word", "quotes"])

func test_symbol_inner():
	var result = javascript.expand(self.string1, 1, 10);
	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 24)
	self.assertEqual(result["string"], "\"foo_bar foo bar\" + \"x\"")
	self.assertEqual(result["type"], "semantic_unit")
	self.assertEqual(result["expand_stack"], ["subword", "word", "quotes", "semantic_unit"])

func test_dont_expand_to_dots():
	var result = javascript.expand(self.string2, 2, 5);
	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 10)
	self.assertEqual(result["string"], " foo.bar ")
	self.assertEqual(result["type"], "quotes")
	self.assertEqual(result["expand_stack"], ["subword", "word", "quotes"])

# func test_expand_to_line():
#   var result = javascript.expand(self.string3, 30, 35);
#   self.assertEqual(result["start"], 28)
#   self.assertEqual(result["end"], 37)
#   self.assertEqual(result["string"], "foo: true")
#   self.assertEqual(result["type"], "line")
#   self.assertEqual(result["expand_stack"], ["subword", "word", "quotes", "semantic_unit", "symbols", "line"])

func test_expand_to_symbol_from_line():
	var result = javascript.expand(self.string3, 28, 37);
	self.assertEqual(result["start"], 23)
	self.assertEqual(result["end"], 40)
	self.assertEqual(result["string"], "\n    foo: true\n  ")
	self.assertEqual(result["type"], "symbol")
	self.assertEqual(result["expand_stack"], ["semantic_unit", "symbols"])

func test_skip_some_because_of_linebreak():
	var result = javascript.expand(self.string3, 22, 41);
	self.assertEqual(result["start"], 15)
	self.assertEqual(result["end"], 41)
	self.assertEqual(result["string"], "return {\n    foo: true\n  }")
	self.assertEqual(result["type"], "semantic_unit")
	self.assertEqual(result["expand_stack"], ["semantic_unit"])

func test_skip_some_because_of_linebreak_2():
	var result = javascript.expand(self.string3, 15, 41);
	self.assertEqual(result["start"], 12)
	self.assertEqual(result["end"], 42)
	self.assertEqual(result["type"], "symbol")
	self.assertEqual(result["expand_stack"], ["semantic_unit", "symbols"])

func test_symbols_in_string_01():
	var result = javascript.expand(self.string4, 35, 42);
	self.assertEqual(result["start"], 30)
	self.assertEqual(result["end"], 42)
	self.assertEqual(result["type"], "semantic_unit")
	self.assertEqual(result["expand_stack"], ["semantic_unit"])

func test_symbols_in_string_02():
	var result = javascript.expand(self.string4, 30, 42);
	self.assertEqual(result["start"], 29)
	self.assertEqual(result["end"], 43)
	self.assertEqual(result["type"], "symbol")
	self.assertEqual(result["expand_stack"], ["semantic_unit", "symbols"])

func test_symbols_in_string_03():
	var result = javascript.expand(self.string4, 29, 43);
	self.assertEqual(result["start"], 29)
	self.assertEqual(result["end"], 46)
	self.assertEqual(result["type"], "semantic_unit")
	self.assertEqual(result["expand_stack"], ["semantic_unit"])

func test_symbols_in_string_04():
	var result = javascript.expand(self.string4, 29, 46);
	self.assertEqual(result["start"], 28)
	self.assertEqual(result["end"], 47)
	self.assertEqual(result["type"], "symbol")
	self.assertEqual(result["expand_stack"], ["semantic_unit", "symbols"])

func test_symbols_in_string_05():
	var result = javascript.expand(self.string4, 28, 47);
	self.assertEqual(result["start"], 23)
	self.assertEqual(result["end"], 55)
	self.assertEqual(result["type"], "quotes")
	self.assertEqual(result["expand_stack"], ["subword", "word", "quotes"])


func assertEqual(a, b):
	assert_that(a).is_equal(b)
