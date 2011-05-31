lib = require('./lib')
base64 = require('../lib/base64')

# API
# ---------

# A binding for the webdriver API as documented [here](http://code.google.com/p/selenium/wiki/JsonWireProtocol).

# webElement
# ---------

# The webElement object represents an element in the target's DOM.

class webElement
	constructor: (@context, @elementId) ->

	getOptions: (override) ->
		suffix = override['path']
		override['path'] = '/element/' + @elementId
		override['path'] += suffix if suffix
		@context.getOptions(override)
	
	# **webElement.clear** - clear an input box or textarea.
	clear: (callback) ->
		lib.restPost(this.getOptions({path: '/clear'}), (response, headers) -> callback(response))

	# **webElement.click** - click on the element.
	click: (callback) ->
		lib.restPost(this.getOptions({path: '/click'}), (response, headers) -> callback(response))

	# **webElement.cssProperty** - get the value for a given css property. returns string.
	cssProperty: (propertyName, callback) ->
		lib.restGet(this.getOptions({path: '/css/' + propertyName}), (response, headers) -> callback(response))
	
	# **webElement.displayed** - determine if the element is currently visible. returns boolean.
	displayed: (callback) ->
		lib.restGet(this.getOptions({path: '/displayed'}), (response, headers) -> callback(response))

	# **webElement.drag** - drag the element the given distance. x is the horizontal offset and y is the vertical offset.
	drag: (x, y, callback) ->
		lib.restPost(this.getOptions({path: '/click'}), {x: x, y: y}, (response, headers) -> callback(response))

	# **webElement.enabled** - determine if the element is currently enabled. returns boolean.
	enabled: (callback) ->
		lib.restGet(this.getOptions({path: '/enabled'}), (response, headers) -> callback(response))

	# **webElement.hover** - move the mouse over the element.
	hover: (callback) ->
		lib.restPost(this.getOptions({path: '/hover'}), (response, headers) -> callback(response))

	# **webElement.location** - get the location of the element. returns {x, y}.
	location: (callback) ->
		lib.restGet(this.getOptions({path: '/location'}), (response, headers) -> callback({x: response.x, y: response.y}))

	# **webElement.name** - get the tag name of the element. returns string.
	name: (callback) ->
		lib.restGet(this.getOptions({path: '/name'}), (response, headers) -> callback(response))

	# **webElement.selected** - determine if the element is selected.
	selected: (callback) ->
		lib.restGet(this.getOptions({path: '/selected'}), (response, headers) -> callback(response))

	# **webElement.setValue** - type a string into the element.
	setValue: (text, callback) ->
		text = text.split('') if typeof text == 'string'
		lib.restPost(this.getOptions({path: '/value'}), {value: text}, (response, headers) -> callback(response))

	# **webElement.submit** - submit a form.
	submit: (callback) ->
		lib.restPost(this.getOptions({path: '/submit'}), (response, headers) -> callback(response))

	# **webElement.text** - get an element's text. returns string.
	text: (callback) ->
		lib.restGet(this.getOptions({path: '/text'}), (response, headers) -> callback(response))

	# **webElement.toggle** - toggle a checkbox or radiobutton.
	toggle: (callback) ->
		lib.restPost(this.getOptions({path: '/toggle'}), (response, headers) -> callback(response))

	# **webElement.value** - get the value of the element. returns string.
	value: (callback) ->
		lib.restGet(this.getOptions({path: '/value'}), (response, headers) -> callback(response))

exports.webElement = (context, elementId) -> new webElement(context, elementId)

# webdriver
# ---------

# The webdriver object represents the browser.

# **webdriver.init** - initialize the browser session.
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

# **webdriver.activeElement** - get the element with focus. returns webElement.
exports.activeElement = (callback) ->
	context = this
	lib.restPost(this.getOptions({path: '/element/active'}), (response, headers) ->
		callback(new webElement(context, response.ELEMENT))
	)

# **webdriver.click** - click the mouse at the current mouse position. optionally provide the mouse button to click: left = 0, middle = 1, right = 2.
exports.click = (button, callback) ->
	if typeof button == 'function'
		callback = button
		button = 0 # left

	lib.restPost(this.getOptions({path: '/click'}), {button: button}, (response, headers) -> callback())

# **webdriver.close** - close the browser.
exports.close = (callback) ->
	lib.restDelete(this.getOptions({path: '/window'}), (response, headers) -> callback())	

# **webdriver.exit** - terminate the process.
exports.exit = () ->
	lib.restDelete(this.getOptions(), (response, headers) -> process.exit(0))

# **webdriver.get** - open the provided url in the browser.
exports.get = (url, callback) ->
	lib.restPost(this.getOptions({path: '/url'}), {url: url}, (response, headers) -> callback())

# **webdriver.getElementById** - retrieve an element in the dom by its id. returns webElement if found.
exports.getElementById = (id, callback) ->
	lib.getElement(this, 'id', id, callback)

# **webdriver.getElementByName** - retrieve an element in the dom by its name attribute. returns webElement if found.
exports.getElementByName = (name, callback) ->
	lib.getElement(this, 'name', name, callback)

# **webdriver.getElementByTag** - retrieve an element in the dom by its tag name. returns webElement if found.
exports.getElementByTag = (tag, callback) ->
	lib.getElement(this, 'tag name', tag, callback)

# **webdriver.getElementsByClass** - retrieve elements in the dom by their class attribute. returns webElement array if found.
exports.getElementsByClass = (cl, callback) ->
	lib.getElements(this, 'class name', cl, callback)

# **webdriver.getElementsBySelector** - retrieve elements in the dom by matching a css selector. returns webElement array if found.
exports.getElementsBySelector = (selector, callback) ->
	lib.getElements(this, 'css selector', selector, callback)

# **webdriver.getElementsByTag** - retrieve elements in the dom by their tag name. returns webElement array if found.
exports.getElementsByTag = (tag, callback) ->
	lib.getElements(this, 'tag name', tag, callback)

# **webdriver.getAnchorByText** - retrieve an anchor element in the dom by matching the provided text. returns webElement if found.
exports.getAnchorByText = (text, callback) ->
	lib.getElement(this, 'link text', text, callback)

# **webdriver.getAnchorByPartialText** - retrieve an anchor element in the dom by partial matching the provided text. returns webElement if found.
exports.getAnchorByPartialText = (text, callback) ->
	lib.getElement(this, 'partial link text', text, callback)

# **webdriver.getAnchorsByText** - retrieve anchor elements in the dom by matching the provided text. returns webElement array if found.
exports.getAnchorsByText = (text, callback) ->
	lib.getElements(this, 'link text', text, callback)

# **webdriver.getAnchorsByPartialText** - retrieve anchor elements in the dom by partial matching the provided text. returns webElement array if found.
exports.getAnchorsByPartialText = (text, callback) ->
	lib.getElements(this, 'partial link text', text, callback)

# **webdriver.getUrl** - get the current url. returns string.
exports.getUrl = (callback) ->
	lib.restGet(this.getOptions({path: '/url'}), (response, headers) -> callback(response))

# **webdriver.moveTo** - moves the mouse to a specific position or element. destination can be {x: x, y: y}, {element: webElement}, {x: x, y: y, element: webElement}. not supported in all browsers.
exports.moveTo = (destination, callback) ->
	moveTo = {}
	
	if destination['x'] and destination['y']
		moveTo['xoffset'] = destination.x
		moveTo['yoffset'] = destination.y
	if destination['element']
		moveTo['element'] = destination['element'].elementId
	
	lib.restPost(this.getOptions({path: '/moveto'}), moveTo, (response, headers) -> callback(response))

# **webdriver.moveTo** - takes a screenshot of the viewport and writes it to the provided filename under the artifacts directory.
exports.screenshot = (file, callback) ->
	context = this
	cb = callback
	f = file
	lib.restGet(this.getOptions({path: '/screenshot'}), (response, headers) ->
		data = base64.decode(response)
		context.saveArtifact(f, data, cb)
	)

# **webdriver.source** - get the current page source. returns string.
exports.source = (callback) ->
	lib.restGet(this.getOptions({path: '/source'}), (response, headers) -> callback(response))

# **webdriver.title** - get the current page title. returns string.
exports.title = (callback) ->
	lib.restGet(this.getOptions({path: '/title'}), (response, headers) -> callback(response))
