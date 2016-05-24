angular.module('SampleCode.directives').directive 'accountProducts', (paginatedResource, AccountProduct, searchResources, $window)->
  restrict: 'A'
  require: 'ngModel'
  scope: {}
  templateUrl: 'account/products.html'
  link: ($scope, element, attrs, model)->
    model.$render = ->
      $scope.account_id = model.$viewValue
      if $scope.account_id
        paginatedResource.apply($scope, AccountProduct, 'products', additionalParameters: {account_id: $scope.account_id})
        searchResources.apply($scope,'term', $scope.productsReloadItems)

    $scope.goToSurveyResults = (tool) ->
      $window.location.href = "/tools/" + tool.id + "/rate_details?account_id=" + $scope.account_id
