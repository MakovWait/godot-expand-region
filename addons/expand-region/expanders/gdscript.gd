extends RefCounted


var javasript = preload("res://addons/expand-region/expanders/javascript.gd").new()


func expand(string, start, end):
	return javasript.expand(string, start, end)
