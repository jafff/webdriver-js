webdriver = require('../src/main')
flow = require('./flow')

browser = webdriver.remote()
browser.debug = false
browser.capabilities.browserName = 'firefox'

flow.exec(
	() ->
		browser.init(this)
	, (id) ->
		browser.get('http://www.google.ca', this)
	, () ->
		console.log 'Menu items:'
		browser.getElementsByClass('gbts', this)
	, (elements) ->
		flow.serialForEach(elements, (element) ->
			element.getText(this)
		, (elementText) ->
			console.log elementText
		, this)
	, () ->
		browser.activeElement(this)
	, (element) ->
		element.setValue('webdriver', this)
	, () ->
		browser.getElementByName('btnG', this)
	, (element) ->
		element.click(this)
	, () ->
		browser.getUrl(this)
	, (url) ->
		console.log 'Arrived at ' + url
		browser.close(this)
	, () ->
		browser.exit()
)
