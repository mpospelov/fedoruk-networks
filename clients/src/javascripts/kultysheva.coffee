class @FormController
  constructor: (@$http, @$scope) ->
    @$scope.formData = []
    @$scope.responseValue = ""

  submitForm: ->
    self = @
    @$http.post('http://localhost:4567/akultisheva', @$scope.formData).then (response)->
      self.$scope.responseValue = response.data
      self.$scope.imageUrl = response.data.output.url
@App = angular.module('app', [])
        .controller "FormController", FormController
