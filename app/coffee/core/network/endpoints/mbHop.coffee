# Wrapper for Hop endpoint
#
# @author Torstein Thune
# @copyright 2015 Microbrew.it
angular.module('Microbrewit/core/Network')
.factory('mbHop', [
	'mbRequest'
	'ApiUrl'
	'notification'
	'localStorage'
	(mbRequest, ApiUrl, notification, localStorage) ->
		endpoint = 'hops'
		factory = {}

		factory.get = (id = null, from = 0, size = 20) ->
			if id
				requestUrl = "#{ApiUrl}/#{endpoint}/#{id}"
				return mbRequest.get(requestUrl, {
					returnProperty: endpoint
				})
			else
				requestUrl = "#{ApiUrl}/#{endpoint}?size=1000"
				return mbRequest.get(requestUrl, { 
					cache: endpoint
					returnProperty: endpoint
					fullscreenLoading: true
				})

		# Update a ingredient
		# @param [ingredient Object] ingredient
		factory.update = (ingredient) ->
			unless ingredient.id 
				notification.add
					title: "Can't edit ingredient" # required
					body: "You did not select a ingredient to edit, or the ingredient you wanted to edit does not exist." # optional
					type: 'error'
					time: 2000 # default: null, ms until autoclose

			requestUrl = "#{ApiUrl}/#{endpoint}/#{ingredient.id}"

			return mbRequest.put(requestUrl, ingredient)

		# Add a new ingredient
		factory.add = (ingredient) ->
			requestUrl = "#{ApiUrl}/#{endpoint}"

			return mbRequest.post(requestUrl, ingredient)

		# Delete a ingredient
		# @todo implement
		factory.delete = (ingredient) ->
			requestUrl = "#{ApiUrl}/#{endpoint}"

			return mbRequest.delete(requestUrl, ingredient.id)

		return factory
])