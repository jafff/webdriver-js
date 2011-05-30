webdriver = require('../src/main')
flow = require('./flow')

browser = webdriver.remote()
browser.debug = false
browser.capabilities.browserName = 'htmlunit'

flow.exec(
	() ->
		browser.init(this)
	, (id) ->
		browser.get('http://www.google.ca', this)
	, () ->
		browser.getElementById('hplogo', this)
	, (element) ->
		element.location(this)
	, (location) ->
		console.log location
		browser.getElementById('gb_10', this)
	, (element) ->
		element.displayed(this)
	, (visible) ->
		console.log 'Visible: ' + visible
		browser.getElementById('gbztms', this)
	, (element) ->
		element.click(this)
	, () ->
		browser.getElementById('gb_10', this)
	, (element) ->
		element.displayed(this)
	, (visible) ->
		console.log 'Visible: ' + visible
		browser.getElementByName('q', this)
	, (element) ->
		element.setValue('webdriver', this)
	, () ->
		browser.getElementByName('btnG', this)
	, (element) ->
		browser.moveTo({element: element}, this)
	, () ->
		browser.click(this)
	, () ->
		browser.getUrl(this)
	, (url) ->
		console.log 'Arrived at ' + url
		browser.close(this)
	, () ->
		browser.exit()
)
