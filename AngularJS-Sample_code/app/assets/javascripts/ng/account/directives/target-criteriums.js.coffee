angular.module('SampleCode.directives').directive 'targetCriteriums', ($http, Trial)->
  restrict: 'C'
  require: 'ngModel'
  scope: {
    trial: '='
  }
  templateUrl: 'account/target-criteriums.html'
  link: ($scope, element, attrs, model)->

    model.$render = ()->
      $scope.target_criteriums = model.$viewValue || []

    $scope.removeTargetCriterium = (target_criterium)->
      if target_criterium.id
        target_criterium._destroy = 1
      else
        $scope.target_criteriums.remove(target_criterium)

    populateCounters = ->
      for criteria in $scope.target_criteriums
        unless criteria.targetable_count
          $http.get("/api/targetables/#{criteria.targetable_id}/counter.json?targetable_type=#{criteria.targetable_type}").success (data)->
            criteria.targetable_count = data.responders_count

    watchFunction = ->
      populateCounters()
      # viewValue = $scope.target_criteriums.map (target)->
      #   {targetable_id: target.targetable.id, targetable_type: target.targetable.type, id: target.id, _destroy: target._destroy}
      # model.$setViewValue(viewValue)

    $scope.$watch 'target_criteriums.length', watchFunction, true
