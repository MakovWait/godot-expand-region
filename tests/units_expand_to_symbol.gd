extends GdUnitTestSuite


var expand_to_symbols = preload("res://addons/expand-region/expanders/expand_to_symbols.gd").new()


var string1
var string2
var string3


func before():
	string1 = FileAccess.open("res://tests/snippets/symbol_01.txt", FileAccess.READ).get_as_text()
	string2 = FileAccess.open("res://tests/snippets/symbol_02.txt", FileAccess.READ).get_as_text()
	string3 = FileAccess.open("res://tests/snippets/symbol_03.txt", FileAccess.READ).get_as_text()


func test_symbol_inner():
	var result = expand_to_symbols.expand_to_symbols(self.string1, 7, 10)

	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 10)
	self.assertEqual(result["string"], "foo - bar")

func test_symbol_outer():
	var result = expand_to_symbols.expand_to_symbols(self.string1, 1, 10)
	self.assertEqual(result["start"], 0)
	self.assertEqual(result["end"], 11)
	self.assertEqual(result["string"], "(foo - bar)")

func test_look_back_dont_hang():
	var result = expand_to_symbols.expand_to_symbols("   ", 1, 2)
	self.assertEqual(result, null)

func test_look_ahead_dont_hang():
	var result = expand_to_symbols.expand_to_symbols("(   ", 2, 2)
	self.assertEqual(result, null)

func test_fix_look_back():
	var result = expand_to_symbols.expand_to_symbols(self.string2, 32, 32)
	self.assertEqual(result["start"], 12)
	self.assertEqual(result["end"], 35)
	self.assertEqual(result["string"], "foo.indexOf('bar') > -1")

func test_respect_symbols_in_selection1():
	var result = expand_to_symbols.expand_to_symbols("(a['value'])", 6, 11)
	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 11)
	# self.assertEqual(result["string"], "foo.indexOf('bar') > -1")

func test_respect_symbols_in_selection():
	var result = expand_to_symbols.expand_to_symbols(self.string3, 10, 61)
	self.assertEqual(result["start"], 5)
	self.assertEqual(result["end"], 66)
	# self.assertEqual(result["string"], "foo.indexOf('bar') > -1")

func test_ignore_symbols_in_strings():
	var result = expand_to_symbols.expand_to_symbols("{'a(a'+bb+'c)c'}", 8, 8)
	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 15)
	self.assertEqual(result["type"], "symbol")


func assertEqual(a, b):
	assert_that(a).is_equal(b)
