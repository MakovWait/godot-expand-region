extends GdUnitTestSuite


var python = preload("res://addons/expand-region/expanders/python.gd").new()


var string1
var string2

func expand(str, start, end, _arg):
	return python.expand(str, start, end)

func before():
	string1 = FileAccess.open("res://tests/snippets/python_01.txt", FileAccess.READ).get_as_text()
	string2 = FileAccess.open("res://tests/snippets/python_02.txt", FileAccess.READ).get_as_text()

func test_expand_to_subword1():
	var result = expand(self.string1, 208, 208, "python")
	self.assertEqual(result["start"], 206)
	self.assertEqual(result["end"], 209)

func test_expand_to_word1():
	var result = expand(self.string1, 206, 209, "python")
	self.assertEqual(result["start"], 206)
	self.assertEqual(result["end"], 213)

func test_expand_to_parens1():
	var result = expand(self.string1, 206, 213, "python")
	self.assertEqual(result["start"], 206)
	self.assertEqual(result["end"], 218)

func test_expand_to_parens2():
	var result = expand(self.string1, 206, 218, "python")
	self.assertEqual(result["start"], 205)
	self.assertEqual(result["end"], 219)

func test_expand_to_semantic_unit1():
	var result = expand(self.string1, 205, 219, "python")
	self.assertEqual(result["start"], 204)
	self.assertEqual(result["end"], 219)

func test_expand_to_line1():
	var result = expand(self.string1, 204, 219, "python")
	self.assertEqual(result["start"], 195)
	self.assertEqual(result["end"], 219)

func test_expand_to_indent1():
	var result = expand(self.string1, 195, 219, "python")
	self.assertEqual(result["start"], 183)
	self.assertEqual(result["end"], 237)

func test_expand_to_indent2():
	var result = expand(self.string1, 183, 237, "python")
	self.assertEqual(result["start"], 169)
	self.assertEqual(result["end"], 237)

func test_expand_to_indent3():
	var result = expand(self.string1, 169, 237, "python")
	self.assertEqual(result["start"], 90)
	self.assertEqual(result["end"], 259)

func test_expand_to_indent4():
	var result = expand(self.string1, 90, 259, "python")
	self.assertEqual(result["start"], 63)
	self.assertEqual(result["end"], 259)

func test_expand_to_indent5():
	var result = expand(self.string1, 63, 259, "python")
	self.assertEqual(result["start"], 63)
	self.assertEqual(result["end"], 292)

func test_expand_to_indent6():
	var result = expand(self.string1, 63, 292, "python")
	self.assertEqual(result["start"], 44)
	self.assertEqual(result["end"], 292)

func test_expand_not_to_no_indent():
	var result = expand(self.string1, 44, 292, "python")
	self.assertEqual(result, null)

func test_expand_from_block_start1():
	var result = expand(self.string1, 177, 182, "python")
	self.assertEqual(result["start"], 169)
	self.assertEqual(result["end"], 237)

func test_expand_from_block_start2():
	var result = expand(self.string1, 67, 89, "python")
	self.assertEqual(result["start"], 63)
	self.assertEqual(result["end"], 259)

func test_expand_from_block_start3():
	var result = expand(self.string1, 44, 62, "python")
	self.assertEqual(result["start"], 44)
	self.assertEqual(result["end"], 292)

func test_expand_over_line_cont1():
	var result = expand(self.string2, 16, 28, "python")
	self.assertEqual(result["start"], 12)
	self.assertEqual(result["end"], 81)

func test_expand_from_block_start4():
	var result = expand(self.string2, 12, 81, "python")
	self.assertEqual(result["start"], 12)
	self.assertEqual(result["end"], 116)

func assertEqual(a, b):
	assert_that(a).is_equal(b)
