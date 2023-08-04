extends RefCounted


var python = preload("res://addons/expand-region/expanders/python.gd").new()


func expand(string, start, end):
	return python.expand(string, start, end)
