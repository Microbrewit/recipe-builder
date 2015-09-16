# 
# Methods for gettings, setting, logging in and out users.
#
# @author Torstein Thune
# @copyright 2014 Microbrew.it
angular.module('Microbrewit/core/Network')
.factory('mbUser', [
	'$http'
	'mbRequest'
	'ClientUrl'
	'$rootScope'
	'localStorage'
	'notification'
	'ApiUrl'
	($http, mbRequest, ClientUrl, $rootScope, localStorage, notification, ApiUrl) ->
		factory = {}
		endpoint = '/users'

		factory.getLoggedUser = (options = {}) ->
			requestUrl = "/getloggeduser"

			# Enable a fullscreen loading screen
			if options.fullscreenLoading
				$rootScope.loading++

			# Return cached if available
			if options.cache?
				console.log 'RETURN CACHE'
				cache = localStorage.getItem(options.cache)
				console.log cache
				if cache
					return new Promise((fulfill) ->
						if options.fullscreenLoading
							$rootScope.loading--
						fulfill(cache)
					)
			
			# Add callback
			if requestUrl.indexOf('?') is -1
				requestUrl += "?callback=JSON_CALLBACK"
			else
				requestUrl += "&callback=JSON_CALLBACK"

			console.log "GET: #{requestUrl}"

			# Create promise
			promise = $http.jsonp(requestUrl, {})
				.error((data, status, headers) ->
					$rootScope.loading-- if options.fullscreenLoading
					console.error("GET #{requestUrl} gave HTTP #{status}")
					console.error(data)

					if headers('refresh_token')
						token = 
							expires: new Date(headers('.expires')).getTime()
							token: headers('access_token')
							refresh: headers('refresh_token')

						if localStorage.getItem('token')
							localStorage.setItem('token', token)

					notification.add
						title: "Error #{status}" # required
						body: 'Could not get data from server' # optional
						type: 'error'
						time: 5000 # default: null, ms until autoclose
						#medium: 'native' # default: null, native = browser Notification API
				)
				.then((response) ->

					# Save auth token
					if response.headers('refresh_token')
						token = 
							expires: new Date(response.headers('.expires')).getTime()
							token: response.headers('access_token')
							refresh: response.headers('refresh_token')
						
						$rootScope.token = token

						# We only store the token in localstorage if the user chose to be remembered on login
						if localStorage.getItem('token')
							localStorage.setItem('token', token)

					$rootScope.loading-- if options.fullscreenLoading

					returnData = response.data
					if options.returnProperty? and response.data[options.returnProperty]?
						returnData = response.data[options.returnProperty]

					localStorage.setItem(options.cache, returnData) if options.cache?

					return returnData
				)

			return promise

		# Get a single or several beers
		# @param [Object] query
		# @option query [Number] id Id of beer to get (if single)
		# @option query [Number] from Offset
		# @option query [Number] size Number of items to return
		# @option query [String] query Search string
		factory.get = (query = {}) ->
			# Get specific beer
			if query.id
				requestUrl = "#{endpoint}/#{query.id}"

			# Get beer with query string
			else if query.query?
				query.from ?= 0
				query.size ?= 20
				
				requestUrl = "#{endpoint}?query=#{query.query}&from=#{query.from}&size=#{query.size}"

			# Get latest added beers
			else if query.latest
				query.from ?= 0
				query.size ?= 20
				requestUrl = "#{endpoint}?from=#{query.from}&size=#{query.size}"

			# Get beers
			else
				requestUrl = "#{endpoint}"

			return mbRequest.get(requestUrl)

		# Get a single beer. Works if you need to be absolutely sure that you only get a single beer
		# @param [Number] id
		factory.getSingle = (id) ->
			unless id
				notification.add
					title: "Can't find user" # required
					body: "We can't find the user you asked for." # optional
					type: 'error'
					time: 2000 # default: null, ms until autoclose
					#medium: 'native' # default: null, native = browser Notification API
			else
				requestUrl = "#{endpoint}/#{id}"
				console.log "mbRequest.get = #{mbRequest.get?}"
				return mbRequest.get(requestUrl)

		# Search in users endpoint
		# @param [String] query Querystring to search for
		factory.search = (query) ->
			requestUrl = "#{endpoint}?query=#{query}&callback=JSON_CALLBACK"

			return mbRequest.get(requestUrl)

		# Login a user, we need either username + password or a token object
		# @param [String] username
		# @param [String] password
		# @param [Object] token
		factory.login = (username, password, token=false) ->

			console.log "username: #{username}"
			# AUTH using token
			if token
				console.log "Using refresh token"
				console.log token.refresh
				dataPayload = "grant_type=refresh_token&refresh_token=#{token.refresh}"

			# AUTH using un/pw
			else if username and password
				dataPayload = "grant_type=password&username=#{username}&password=#{password}"

			dataPayload+="&client_id=#{ClientUrl}"

			promise = $http({
				url: "#{ApiUrl}/token"
				method: "POST"
				#withCredentials: true
				data: dataPayload
				headers:
					"Content-Type": "application/x-www-form-urlencoded"
			})
			.error((data, status) ->
				$rootScope.token = null
				#localStorage.removeItem('token')
				$rootScope.user = null
				console.log 'We received error'
				notification.add
					title: 'Authentication error' # required
					body: 'Wrong username/password' # optional
					type: 'error full-width'
					time: 50000 # default: null, ms until autoclose
					#medium: 'native' # default: null, native = browser Notification API

			)
			.then((response) ->
				notification.add
					title: "Welcome back, #{response.data.username}" # required
					#body: 'Wrong username/password' # optional
					type: 'success'
					time: 2000 # default: null, ms until autoclose
					#medium: 'native' # default: null, native = browser Notification API

				# Save Token
				console.log 'we received then'
				console.log response
				token = 
					expires: new Date(response.data['.expires']).getTime()
					token: response.data['access_token']
					refresh: response.data['refresh_token']

				$rootScope.token = token
				localStorage.setItem('token', token)

				return response.data.username
			)
			
			return promise

		# Since we use tokens, we know that the token will be invalid soon and that it isnt stored anywhere else
		# Therefore we only need to remove all references to the user object and the token
		factory.logout = () ->
			$rootScope.user = null
			$rootScope.token = null
			localStorage.removeItem('user')
			localStorage.removeItem('token')

		# Update user
		# @todo Implement
		factory.update = () ->
			console.log 'USER UPDATE NOT IMPLEMENTED'

		return factory
])