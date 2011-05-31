webdriver = require('../src/main')
flow = require('./flow')

host = 'localhost'

browser = webdriver.remote(host)
browser.debug = false
browser.capabilities.browserName = 'chrome'

flow.exec(
	() ->
		browser.init(this)
	, (id) ->
		browser.get('http://www.google.ca', this)
	, () ->
		browser.screenshot('google01.png', this)
	, () ->
		browser.getElementByTag('body', this)
	, (body) ->
		body.cssProperty('font-family', this)
	, (fontfam) ->
		console.log 'Fonts: ' + fontfam
		console.log 'Menu items:'
		browser.getElementsByClass('gbts', this)
	, (elements) ->
		flow.serialForEach(elements, (element) ->
			element.text(this)
		, (elementText) ->
			console.log elementText
		, this)
	, () ->
		browser.activeElement(this)
	, (element) ->
		element.setValue('webdriver', this)
	, () ->
		browser.screenshot('google02.png', this)
	, () ->
		browser.getElementByName('btnG', this)
	, (element) ->
		element.click(this)
	, () ->
		browser.getElementById('toggle_location_link', this)
	, (link) ->
		link.click(this)
	, () ->
		browser.getElementById('lc-input', this)
	, (input) ->
		_this = this
		input.clear(() -> _this(input))
	, (input) ->
		_this = this
		input.setValue('Waterloo, ON', () -> _this(input))
	, (input) ->
		_this = this
		browser.screenshot('google03.png', ()-> _this(input))
	, (input) ->
		input.submit(this)
	, () ->
		browser.source(this)
	, (source) ->
		console.log 'Content length: ' +  source.length
		browser.getUrl(this)
	, (url) ->
		console.log 'Arrived at ' + url
		browser.screenshot('google04.png', this)
	, () ->
		browser.close(this)
	, () ->
		browser.exit()
)
