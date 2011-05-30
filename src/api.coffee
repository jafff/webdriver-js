lib = require('./lib')

class webElement
	constructor: (@context, @elementId) ->

	getOptions: (override) ->
		suffix = override['path']
		override['path'] = '/element/' + @elementId
		override['path'] += suffix if suffix
		@context.getOptions(override)
	
	clear: (callback) ->
		lib.restPost(this.getOptions({path: '/clear'}), (response, headers) -> callback(response))

	click: (callback) ->
		lib.restPost(this.getOptions({path: '/click'}), (response, headers) -> callback(response))

	displayed: (callback) ->
		lib.restGet(this.getOptions({path: '/displayed'}), (response, headers) -> callback(response))

	enabled: (callback) ->
		lib.restGet(this.getOptions({path: '/enabled'}), (response, headers) -> callback(response))

	getText: (callback) ->
		lib.restGet(this.getOptions({path: '/text'}), (response, headers) -> callback(response))

	getValue: (callback) ->
		lib.restGet(this.getOptions({path: '/value'}), (response, headers) -> callback(response))

	hover: (callback) ->
		lib.restPost(this.getOptions({path: '/hover'}), (response, headers) -> callback(response))

	location: (callback) ->
		lib.restGet(this.getOptions({path: '/location'}), (response, headers) -> callback({x: response.x, y: response.y}))

	setValue: (text, callback) ->
		text = text.split('') if typeof text == 'string'
		lib.restPost(this.getOptions({path: '/value'}), {value: text}, (response, headers) -> callback(response))

	submit: (callback) ->
		lib.restPost(this.getOptions({path: '/submit'}), (response, headers) -> callback(response))

	toggle: (callback) ->
		lib.restPost(this.getOptions({path: '/toggle'}), (response, headers) -> callback(response))

exports.webElement = (context, elementId) -> new webElement(context, elementId)

exports.init = (callback) ->
	_this = this
	
	lib.debug = true if _this.debug
	
	lib.restPost(this.getOptions(), {desiredCapabilities: this.capabilities}, (response, headers) ->
		if not headers['location']
			console.log 'Error: failed to get new session'
			process.exit(1)

		sessionUrl = headers['location'].split('/')
		_this.sessionId = sessionUrl[sessionUrl.length - 1]
		callback(_this.sessionId)
	)

exports.activeElement = (callback) ->
	context = this
	lib.restPost(this.getOptions({path: '/element/active'}), (response, headers) ->
		callback(new webElement(context, response.ELEMENT))
	)

exports.click = (button, callback) ->
	if typeof button == 'function'
		callback = button
		button = 0 # left

	lib.restPost(this.getOptions({path: '/click'}), {button: button}, (response, headers) -> callback())

exports.close = (callback) ->
	lib.restDelete(this.getOptions({path: '/window'}), (response, headers) -> callback())	

exports.exit = () ->
	lib.restDelete(this.getOptions(), (response, headers) -> process.exit(0))

exports.get = (url, callback) ->
	lib.restPost(this.getOptions({path: '/url'}), {url: url}, (response, headers) -> callback())

exports.getElementById = (id, callback) ->
	lib.getElement(this, 'id', id, callback)
	
exports.getElementByName = (name, callback) ->
	lib.getElement(this, 'name', name, callback)

exports.getElementByTag = (tag, callback) ->
	lib.getElement(this, 'tag name', tag, callback)
	
exports.getElementsByClass = (cl, callback) ->
	lib.getElements(this, 'class name', cl, callback)

exports.getElementsBySelector = (selector, callback) ->
	lib.getElements(this, 'css selector', selector, callback)

exports.getElementsByTag = (tag, callback) ->
	lib.getElements(this, 'tag name', tag, callback)

exports.getAnchorByText = (text, callback) ->
	lib.getElement(this, 'link text', text, callback)

exports.getAnchorByPartialText = (text, callback) ->
	lib.getElement(this, 'partial link text', text, callback)

exports.getAnchorsByText = (text, callback) ->
	lib.getElements(this, 'link text', text, callback)

exports.getAnchorsByPartialText = (text, callback) ->
	lib.getElements(this, 'partial link text', text, callback)

exports.getUrl = (callback) ->
	lib.restGet(this.getOptions({path: '/url'}), (response, headers) -> callback(response))

exports.moveTo = (destination, callback) ->
	moveTo = {}
	
	if destination['x'] and destination['y']
		moveTo['xoffset'] = destination.x
		moveTo['yoffset'] = destination.y
	if destination['element']
		moveTo['element'] = destination['element'].elementId
	
	lib.restPost(this.getOptions({path: '/moveto'}), moveTo, (response, headers) -> callback(response))

