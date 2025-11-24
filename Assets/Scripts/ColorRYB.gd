class_name ColorRYB_Operations

enum ColorRYB{
	Red = 0,
	Yellow = 1,
	Blue = 2,
	Orange = 3,
	Green = 4,
	Purple = 5,
	White = 6
}

const colorArrays = [
	[1.0, 0.0, 0.0],
	[0.0, 1.0, 0.0],
	[0.0, 0.0, 1.0],
	[1.0, 1.0, 0.0],
	[0.0, 1.0, 1.0],
	[1.0, 0.0, 1.0],
	[1.0, 1.0, 1.0]
]

const colorVisualizeation = [
	Color.RED,
	Color.YELLOW,
	Color.BLUE,
	Color.ORANGE_RED,
	Color.GREEN,
	Color.WEB_PURPLE,
	Color.WHITE
]

static func ToColor(color: ColorRYB) -> Color:
	return colorVisualizeation[color]

static func FromColor(color: Color) -> ColorRYB:
	return colorVisualizeation.find(color)

static func Add(... colors):
	var arrs = colors.map(func(c): return colorArrays[c])
	var new_arr = [0, 0, 0]
	
	for i in range(len(arrs)):
		for j in range(3):
			new_arr[j] = float(new_arr[j] or arrs[i][j])
	
	var res = colorArrays.find(new_arr)
	if res == -1: return null
	else: return res as ColorRYB

static func Split(color):
	var color_arr = colorArrays[color]
	var res = []
	
	for i in range(3):
		if (color_arr[i] == 1.0):
			var new_arr = [0, 0, 0]
			new_arr[i] = 1.0
			res.append(colorArrays.find(new_arr) as ColorRYB)
	return res

static func Filter(color, filter):
	var color_arr = colorArrays[color]
	var filter_arr = colorArrays[filter]
	var new_arr = [0, 0, 0]
	
	for i in range(3):
		new_arr[i] = float(color_arr[i] and filter_arr[i])
	
	var res = colorArrays.find(new_arr)
	
	if res == -1: return null
	else: return res as ColorRYB

static func Invert(color: ColorRYB):
	var arr = colorArrays[color]
	var new_arr = [0,0,0]
	
	for i in range(3):
		new_arr[i] = float(!arr[i])
	
	var res = colorArrays.find(new_arr)
	if res == -1: return null
	else: return res as ColorRYB
