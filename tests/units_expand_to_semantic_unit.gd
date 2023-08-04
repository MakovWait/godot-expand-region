extends GdUnitTestSuite


var _expand_to_semantic_unit = preload("res://addons/expand-region/expanders/expand_to_semantic_unit.gd").new()


var string1
var string2
var string3
var string4
var string5
var string6
var string7
var string8
var string9


func before():
	string1 = FileAccess.open("res://tests/snippets/semantic_unit_01.txt", FileAccess.READ).get_as_text()
	string2 = FileAccess.open("res://tests/snippets/semantic_unit_02.txt", FileAccess.READ).get_as_text()
	string3 = FileAccess.open("res://tests/snippets/semantic_unit_03.txt", FileAccess.READ).get_as_text()
	string4 = FileAccess.open("res://tests/snippets/semantic_unit_04.txt", FileAccess.READ).get_as_text()
	string5 = FileAccess.open("res://tests/snippets/semantic_unit_05.txt", FileAccess.READ).get_as_text()
	string6 = FileAccess.open("res://tests/snippets/semantic_unit_06.txt", FileAccess.READ).get_as_text()
	string7 = FileAccess.open("res://tests/snippets/semantic_unit_07.txt", FileAccess.READ).get_as_text()
	string8 = FileAccess.open("res://tests/snippets/semantic_unit_08.txt", FileAccess.READ).get_as_text()
	string9 = FileAccess.open("res://tests/snippets/semantic_unit_09.txt", FileAccess.READ).get_as_text()


func assertEqual(a, b):
	assert_that(a).is_equal(b)


func expand_to_semantic_unit(string, start, end):
	return _expand_to_semantic_unit.expand_to_semantic_unit(string, start, end)


func test_1():
	var result = expand_to_semantic_unit(self.string1, 13, 13);
	self.assertEqual(result["string"], "foo.bar['property'].getX()")
	self.assertEqual(result["start"], 7)
	self.assertEqual(result["end"], 33)

func test_2():
	var result = expand_to_semantic_unit(self.string2, 13, 13);
	self.assertEqual(result["string"], "foo.bar['prop,erty'].getX()")
	self.assertEqual(result["start"], 7)
	self.assertEqual(result["end"], 34)

func test_3():
	var result = expand_to_semantic_unit(self.string3, 13, 13);
	self.assertEqual(result["string"], "foo.bar['property'].getX()")
	self.assertEqual(result["start"], 13)
	self.assertEqual(result["end"], 39)

func test_4():
	var result = expand_to_semantic_unit(self.string4, 11, 11);
	self.assertEqual(result["start"], 7)
	self.assertEqual(result["end"], 51)

func test_5():
	var result = expand_to_semantic_unit(self.string4, 6, 52);
	self.assertEqual(result["start"], 2)
	self.assertEqual(result["end"], 52)

func test_6():
	var result = expand_to_semantic_unit(self.string5, 15, 15);
	self.assertEqual(result["string"], "o.getData(\"bar\")")
	self.assertEqual(result["start"], 8)
	self.assertEqual(result["end"], 24)

func test_7():
	var result = expand_to_semantic_unit("if (foo.get('a') && bar.get('b')) {", 6, 6);
	self.assertEqual(result["string"], "foo.get('a')")
	self.assertEqual(result["start"], 4)
	self.assertEqual(result["end"], 16)

func test_8():
	var result = expand_to_semantic_unit("if (foo.get('a') || bar.get('b')) {", 6, 6);
	self.assertEqual(result["string"], "foo.get('a')")
	self.assertEqual(result["start"], 4)
	self.assertEqual(result["end"], 16)

func test_9():
	var result = expand_to_semantic_unit(self.string9, 0, 14);
	self.assertEqual(result["string"], "if(foo || bar) {\n}")
	self.assertEqual(result["start"], 0)
	self.assertEqual(result["end"], 18)

func test_should_null():
	var result = expand_to_semantic_unit("aaa", 1, 1);
	self.assertEqual(result, null)

func test_should_null_2():
	var result = expand_to_semantic_unit(self.string6, 6, 23);
	self.assertEqual(result, null)

func test_should_null_3():
	var result = expand_to_semantic_unit(self.string7, 17, 33);
	self.assertEqual(result, null)

func test_should_null_4():
	var result = expand_to_semantic_unit(self.string8, 16, 16);
	self.assertEqual(result, null)

func test_should_null_5():
	var result = expand_to_semantic_unit("aa || bb", 3, 3);
	self.assertEqual(result, null)
