class @FormController
  constructor: (@$http, @$scope) ->
    @$scope.cabinClasses = [
      "Первый класс",
      "Второй класс",
      "Третий класс",
      "Член экипажа"
    ]
    @$scope.ageClasses = ["Ребенок", "Взрослый"]
    @$scope.sexClasses = ["Женщина", "Мужчина"]
    @$scope.formData = {}
    @$scope.responseValue = ""


  submitForm: ->
    self = @
    @$http.post('http://localhost:4567/mpospelov', @$scope.formData).then (response)->
      self.$scope.responseValue = response.data
@App = angular.module('app', [])
        .controller "FormController", FormController
