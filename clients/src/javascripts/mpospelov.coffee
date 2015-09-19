require.config
  paths:
    'angular': '../lib/angular/angular'
  shim:
    angular:
      exports: 'angular'
  deps: ['./bootstrap']

requirejs ["lib/angular/angular.js"], (angular)->
  debugger
  @App = angular.module('App', [])
