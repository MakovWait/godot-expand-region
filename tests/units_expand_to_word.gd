extends GdUnitTestSuite


var _expand_to_word = preload("res://addons/expand-region/expanders/expand_to_word.gd").new()


var string1
var string2
var string3


func before():
	string1 = FileAccess.open("res://tests/snippets/word_01.txt", FileAccess.READ).get_as_text()
	string2 = FileAccess.open("res://tests/snippets/word_02.txt", FileAccess.READ).get_as_text()
	string3 = FileAccess.open("res://tests/snippets/word_03.txt", FileAccess.READ).get_as_text()

func assertEqual(a, b):
	assert_that(a).is_equal(b)

func expand_to_word(string, start, end):
	return _expand_to_word.expand_to_word(string, start, end)

func test_word_with_whitespaces_around():
	var result = expand_to_word(" hello ", 3, 3);
	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 6)
	self.assertEqual(result["string"], "hello")

func test_find_word_with_dot_before():
	var result = expand_to_word("foo.bar", 5, 5);
	self.assertEqual(result["start"], 4)
	self.assertEqual(result["end"], 7)
	self.assertEqual(result["string"], "bar")

func test_find_word_when_string_is_only_the_word():
	var result = expand_to_word("bar", 1, 1);
	self.assertEqual(result["start"], 0)
	self.assertEqual(result["end"], 3)
	self.assertEqual(result["string"], "bar")

func test_find_word_when_parts_of_the_word_are_already_selected():
	var result = expand_to_word("hello", 1, 4);
	self.assertEqual(result["start"], 0)
	self.assertEqual(result["end"], 5)
	self.assertEqual(result["string"], "hello")

func test_dont_find_word1():
	var result = expand_to_word(self.string1, 1, 10);
	self.assertEqual(result, null)

func test_dont_find_word2():
	var result = expand_to_word(" ee ee", 2, 5);
	self.assertEqual(result, null)

func test_dont_find_word3_and_dont_hang():
	var result = expand_to_word("aaa", 0, 3);
	self.assertEqual(result, null)

func test_dont_expand_to_linebreak():
	var result = expand_to_word(self.string2, 0, 0);
	self.assertEqual(result, null)

func test_special_chars1():
	var result = expand_to_word(self.string3, 15, 15)
	self.assertEqual(result["start"], 13)
	self.assertEqual(result["end"], 24)

func test_special_chars2():
	var result = expand_to_word(self.string3, 57, 57)
	self.assertEqual(result["start"], 57)
	self.assertEqual(result["end"], 64)

func test_special_chars3():
	var result = expand_to_word(self.string3, 75, 77)
	self.assertEqual(result["start"], 75)
	self.assertEqual(result["end"], 85)

func test_special_chars4():
	var result = expand_to_word(self.string3, 89, 89)
	self.assertEqual(result["start"], 86)
	self.assertEqual(result["end"], 89)
