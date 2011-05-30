http = require('http')
api = require('./api')

clean = (s) -> (s.charAt(x) for x in [0..s.length-1] when s.charCodeAt(x) != 0).join('')

handleResponse = (statusCode, response, headers, callback) ->
	if statusCode == 500
		console.log 'WebDriver returned 500'
		console.log headers
		process.exit(1)
	
	console.log 'http status: ' + statusCode if exports.debug
	console.log 'response headers: ' + JSON.stringify(headers) if exports.debug

	if response.length > 0
		console.log 'response data: ' + response if exports.debug
		console.log 'clean response data: ' + clean(response) if exports.debug
		response = JSON.parse(clean(response))
		
		if response['status'] == 0
			callback(response['value'], headers)
		else
			console.log 'Error: ' + response['value']['message']
	else
		callback('', headers)
		
restRequest = (options, data, callback) ->
	if typeof data == 'function' and not callback
		callback = data
		data = ''
	console.log 'request options: ' + JSON.stringify(options) if exports.debug
	req = http.request(options, (res) ->
		responseData = ''
		res.setEncoding('utf8')
		res.on('data', (chunk) -> responseData += chunk)
		res.on('end', () -> handleResponse(res.statusCode, responseData, res.headers, callback))
	)
	
	if typeof data != 'string'
		data = JSON.stringify(data)
	console.log 'request data: ' + data if exports.debug
	req.write(data)
	req.end()

exports.getElement = (context, using, value, callback) ->
	exports.restPost(context.getOptions({path: '/element'}), {using: using, value: value}, (response, headers) ->
		callback(api.webElement(context, response.ELEMENT))
	)

exports.getElements = (context, using, value, callback) ->
	exports.restPost(context.getOptions({path: '/elements'}), {using: using, value: value}, (response, headers) ->
		callback((api.webElement(context, x.ELEMENT) for x in response))
	)

exports.restGet = (options, callback) ->
	options['method'] = 'GET'
	restRequest(options, '', callback)

exports.restPost = (options, data, callback) ->
	options['method'] = 'POST'
	if typeof data == 'function'
		callback = data
		data = ''
	restRequest(options, data, callback)

exports.restDelete = (options, data, callback) ->
	options['method'] = 'DELETE'
	restRequest(options, data, callback)

exports.debug = false
