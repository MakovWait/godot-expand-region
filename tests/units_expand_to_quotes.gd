extends GdUnitTestSuite


var _expand_to_quotes = preload("res://addons/expand-region/expanders/expand_to_quotes.gd").new()


var string1
var string2
var string3


func before():
	string1 = FileAccess.open("res://tests/snippets/quote_01.txt", FileAccess.READ).get_as_text()
	string2 = FileAccess.open("res://tests/snippets/quote_02.txt", FileAccess.READ).get_as_text()
	string3 = FileAccess.open("res://tests/snippets/quote_03.txt", FileAccess.READ).get_as_text()


func assertEqual(a, b):
	assert_that(a).is_equal(b)


func expand_to_quotes(string, start, end):
	return _expand_to_quotes.expand_to_quotes(string, start, end)


func test_double_quotes_inner():
	var result = expand_to_quotes(self.string1, 6, 12);
	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 12)
	self.assertEqual(result["string"], "test string")

func test_double_quotes_outer():
	var result = expand_to_quotes(self.string1, 1, 12);
	self.assertEqual(result["start"], 0)
	self.assertEqual(result["end"], 13)
	self.assertEqual(result["string"], "\"test string\"")

func test_single_quotes_inner():
	var result = expand_to_quotes(self.string2, 6, 12);
	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 12)
	self.assertEqual(result["string"], "test string")

func test_single_quotes_outer():
	var result = expand_to_quotes(self.string2, 1, 12);
	self.assertEqual(result["start"], 0)
	self.assertEqual(result["end"], 13)
	self.assertEqual(result["string"], "'test string'")

func test_should_not_find1():
	var result = expand_to_quotes(" ': '", 1, 1);
	self.assertEqual(result, null)

func test_should_not_find2():
	var result = expand_to_quotes("': '", 4, 4);
	self.assertEqual(result, null)

func test_ignore_escaped_quotes():
	var result = expand_to_quotes(self.string3, 2, 2);
	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 13)
	self.assertEqual(result["string"], "test\\\"string")
