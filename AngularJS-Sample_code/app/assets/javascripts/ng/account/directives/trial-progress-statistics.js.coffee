angular.module('SampleCode.directives').directive 'trialProgressStatistics', ->
  restrict: 'C'
  scope: {
    trial: '='
  }
  templateUrl: 'account/trial-progress-statistics.html'
  link: ($scope, element, attrs) ->
