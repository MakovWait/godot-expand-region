extends GdUnitTestSuite


var _expand_to_line = preload("res://addons/expand-region/expanders/expand_to_line.gd").new()


var string1
var string2
var string3


func before():
	string1 = FileAccess.open("res://tests/snippets/line_01.txt", FileAccess.READ).get_as_text()
	string2 = FileAccess.open("res://tests/snippets/line_02.txt", FileAccess.READ).get_as_text()
	string3 = FileAccess.open("res://tests/snippets/line_03.txt", FileAccess.READ).get_as_text()


func assertEqual(a, b):
	assert_that(a).is_equal(b)


func expand_to_line(string, start, end):
	return _expand_to_line.expand_to_line(string, start, end)

func test_with_spaces_at_beginning():
	var result = expand_to_line(self.string1, 10, 16);
	self.assertEqual(result["string"], "is it me")
	self.assertEqual(result["start"], 10)
	self.assertEqual(result["end"], 18)

func test_existing_line_selection():
	var result = expand_to_line(self.string1, 10, 18);
	self.assertEqual(result, null)

func test_with_no_spaces_or_tabs_at_beginning():
	var result = expand_to_line(self.string2, 6, 12);
	self.assertEqual(result["string"], "is it me")
	self.assertEqual(result["start"], 6)
	self.assertEqual(result["end"], 14)

func test_with_indention():
	var result = expand_to_line(" aa", 0, 0);
	self.assertEqual(result["string"], " aa")
	self.assertEqual(result["start"], 0)
	self.assertEqual(result["end"], 3)

func test_without_indention():
	var result = expand_to_line(" aa", 1, 1);
	self.assertEqual(result["string"], "aa")
	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 3)

func test_with_indention2():
	var result = expand_to_line("  aa", 1, 1);
	self.assertEqual(result["string"], "  aa")
	self.assertEqual(result["start"], 0)
	self.assertEqual(result["end"], 4)
