extends GdUnitTestSuite

const utils = preload("res://addons/expand-region/utils.gd")


var linebreak_01
var line_01
var trim_01
var trim_02


func before():
	linebreak_01 = FileAccess.open("res://tests/snippets/linebreak_01.txt", FileAccess.READ).get_as_text()
	line_01 = FileAccess.open("res://tests/snippets/line_01.txt", FileAccess.READ).get_as_text()
	trim_01 = FileAccess.open("res://tests/snippets/trim_01.txt", FileAccess.READ).get_as_text()
	trim_02 = FileAccess.open("res://tests/snippets/trim_02.txt", FileAccess.READ).get_as_text()


func assertEqual(a, b):
	assert_that(a).is_equal(b)


func test_find_linebreak():
	self.assert_that(utils.selection_contain_linebreaks(self.linebreak_01, 0, 8)).is_equal(true)

func test_dont_find_linebreak():
	self.assert_that(utils.selection_contain_linebreaks("aaa", 1, 2)).is_equal(false)


func test_get_line():
	var result = utils.get_line(self.line_01, 13, 13);
	self.assertEqual(result["start"], 8)
	self.assertEqual(result["end"], 18)


func test_1():
	var result = utils.trim("  aa  ");
	self.assertEqual(result["start"], 2)
	self.assertEqual(result["end"], 4)

func test_2():
	var result = utils.trim("  'a a'  ");
	self.assertEqual(result["start"], 2)
	self.assertEqual(result["end"], 7)

func test_3():
	var result = utils.trim(self.trim_01);
	self.assertEqual(result["start"], 2)
	self.assertEqual(result["end"], 11)

func test_4():
	var result = utils.trim(" foo.bar['property'].getX()");
	self.assertEqual(result["start"], 1)
	self.assertEqual(result["end"], 27)

func test_5():
	var result = utils.trim(self.trim_02);
	self.assertEqual(result["start"], 2)
	self.assertEqual(result["end"], 49)
