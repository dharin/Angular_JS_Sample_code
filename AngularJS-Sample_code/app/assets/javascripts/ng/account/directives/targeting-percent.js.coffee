angular.module('SampleCode.directives').directive 'targetingPercent', ($http, Trial)->
  restrict: 'C'
  require: 'ngModel'
  scope: {
    totalUsersCount: '='
    trial: '='
  }
  templateUrl: 'account/targeting-percent.html'
  link: ($scope, element, attrs, model)->

    $scope.target_users_count = 0

    Trial.$put("/api/accounts/#{$scope.trial.account_id}/trials/eligible_users_count", $scope.trial).then (result) ->
      $scope.totalUsersCount = result.count

    $scope.coveragePercent = ()->
      (model.$viewValue / $scope.totalUsersCount) * 100.0

    viewModelFunction = ->
      model.$viewValue

    updateCounters = ->
      Trial.$put("/api/accounts/#{$scope.trial.account_id}/trials/target_users_count", $scope.trial).then (result)->
        model.$setViewValue result.target_count

    vw = ->
      $scope.trial.target_criteria


    $scope.$watch(vw, updateCounters, true)
