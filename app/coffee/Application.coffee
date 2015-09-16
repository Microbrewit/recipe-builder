# Configure Microbrew.it application (import modules + configure router)
# @author Torstein Thune
# @copyright 2014 Microbrew.it
angular.module('Microbrewit', 
	[
		'ui.router' # External
		'ui.select' # External
		'ui.sortable' # External
		'Microbrewit/core/Calculation'
		'Microbrewit/core/Network'
		'Microbrewit/core/Notifications'
		'Microbrewit/core/Utils'
	]
)
	.config ($httpProvider, $stateProvider, $urlRouterProvider, $locationProvider) ->
		# Enable CORS
		$httpProvider.defaults.useXDomain = true

		$locationProvider.html5Mode(true)

		# For any unmatched url, redirect to /state1
		$urlRouterProvider
			.otherwise("/")

		# Now set up the states
		$stateProvider

			.state('add', {
				url: "/beers/add"
				templateUrl: "templates/beers/beer.add.html"
				controller: "RecipeController"
			})
			.state('fork', {
				url: "/beers/:id/fork"
				templateUrl: "templates/beers/beer.add.html"
				controller: "RecipeController"
			})
			.state('edit', {
				url: "/beers/:id/edit"
				templateUrl: "templates/beers/beer.add.html"
				controller: "RecipeController"
			})