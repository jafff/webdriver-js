api = require('./api')
fs = require('fs')

webdriver = (hostname = '127.0.0.1', port = 4444, capabilities = undefined) ->
	capabilities = {} if not capabilities
	this.debug = false

	this.options =
		host: hostname
		port: port
		path: '/wd/hub/session'

	this.capabilities =
		browserName: capabilities['browserName'] or 'chrome'
		version: capabilities['version'] or ''
		javascriptEnabled: capabilities['javascriptEnabled'] or true
		platform: capabilities['platform'] or 'ANY'

	this.getOptions = (override = {}) ->
		opt = {}
		opt[name] = option for name, option of this.options
		opt['path'] += '/' + this.sessionId if this.sessionId != null
		opt['path'] += override['path'] if override['path']
		opt
	
	this.artifactsPath = 'artifacts/'
	this.saveArtifact = (filename, data, callback) ->
		fs.writeFile(this.artifactsPath + filename, data, 'binary', (error) ->
			throw error if error
			callback()
		)

	this[key] = f for key, f of api
	this.sessionId = null

# **webdriver.remote** - returns a new webdriver object
exports.remote = (hostname, port, capabilities = undefined) -> new webdriver(hostname, port, capabilities)

