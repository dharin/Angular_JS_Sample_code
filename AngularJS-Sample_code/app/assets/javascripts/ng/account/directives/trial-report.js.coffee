angular.module('SampleCode.directives').directive 'trialReport',
  ($rootScope, $location, paginatedResource, AccountProduct, Trial, TrialParticipants, TrialQuestion, pageModes, searchResources, Results, orderByFilter)->
    restrict: 'A'
    require: 'ngModel'
    scope: {
      accountId: '&'
    }
    templateUrl: 'account/report.html'
    link: ($scope, element, attrs, model)->
      angular.extend($scope, pageModes)
      $scope.mode = 'results'
      $scope.orderingObject = {}
      $scope.trial_products = []
      $scope.selectedProduct = undefined
      $scope.productSummary = false
      $scope.sort_term = 'name'
      $scope.sort_direction = 'asc'
      $scope.loaderDefined = true
      $scope.isProductLoading = true
      $scope.isParticipantLoading = true
      $scope.isExported = undefined

      $scope.selectProduct = (product)->
        # $scope.setMode('participants')
        # $scope.selectedProduct = product
        $scope.setMode('results')
        $rootScope.$emit('selectProduct', product);

      $scope.back = ()->
        $scope.selectedProduct = undefined
        $scope.at_least_one_grade = false
        $scope.setMode('products')


      model.$render = ->
        $scope.selectedProduct = undefined
        $scope.questions = undefined
        $scope.at_least_one_grade = false
        $scope.trial = model.$viewValue

        if $scope.trial
          TrialQuestion.query({},{account_id: $scope.accountId(),trial_id: $scope.trial.id}).then (questions)->
            $scope.questions = questions
          paginatedResource.apply($scope, AccountProduct, 'trial_products',
            additionalParameters: {account_id: $scope.accountId()}, queryParameters: {trial_id: $scope.trial.id, per_page: 20})
          paginatedResource.apply($scope, TrialParticipants, 'trial_participants',
            additionalParameters: {account_id: $scope.accountId(), trial_id: $scope.trial.id}, queryParameters: {term: $scope.trial_participants_term})
          searchResources.apply($scope, 'trial_participants_term', $scope.trial_participantsReloadItems)
          searchResources.apply($scope, 'at_least_one_grade', $scope.trial_participantsReloadItems)

          if $scope.trial.tools.length == 1
            $scope.selectProduct($scope.trial.tools[0])

      $scope.hideLoader = (resource) ->
        $scope.isProductLoading = false if resource == "trial_products"
        $scope.isParticipantLoading = false if resource == "trial_participants"

      modelValue = ->
        model.$viewValue

      $scope.$watch modelValue, ->
        $scope.mode = 'results'
        $scope.selectedProduct = undefined


      $scope.orderParticipants = (eObj, sort_term) ->
        $location.search('sort_term', sort_term)
        $location.search('sort_direction', if eObj.target.className.search("asc") > 0 then 'asc' else 'desc')
        $scope.trial_participantsReloadItems()

      $scope.export = ->
        Trial.$post("/api/accounts/#{$scope.trial.account_id}/trials/#{$scope.trial.id}/export").then((data)->
          $scope.isExported = true
          return
        ,(error) ->
          $scope.isExported = false
          return
        )
