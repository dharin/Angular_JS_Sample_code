angular.module('SampleCode.directives').directive 'trialResults', ($rootScope, Results, TrialSurveys, SurveyQuestionAnwer, AccountProduct, pageModes)->
  restrict: 'A'
  require: 'ngModel'
  scope: {
    toolIds: '&'
  }
  templateUrl: 'account/trial-results.html'
  link: ($scope, element, attrs, model)->
    angular.extend($scope, pageModes)
    $scope.setMode('results')
    $scope.orderingObject = {}
    $scope.comment_page = 1
    $scope.results_page = 1
    $scope.breadcrumbs = [
      {title: 'Results', active: true}
    ]

    loadResults = (page)->
      params = {account_id: $scope.trial.account_id,trial_id: $scope.trial.id}
      requestParams = {tool_id: $scope.tool?.id, page: page, 'tool_ids[]': $scope.toolIds()}
      if $scope.orderingObject.key
        ordering_string = $scope.orderingObject.key + '/' + $scope.orderingObject.direction
        angular.extend(requestParams,{ordering_string: ordering_string} )

      if $scope.tool
        TrialSurveys.get(params, requestParams).then (r)->
          $scope.trial_surveys = r
          $scope.surveys_total_count = r.total_items
      else
        Results.get(params, requestParams).then (r)->
          $scope.results = r
          $scope.results_total_count = r.total_items

    loadComments = (page)->
      params = {account_id: $scope.trial.account_id,trial_id: $scope.trial.id}
      SurveyQuestionAnwer.query({survey_question_id: $scope.question.id, tool_id: $scope.tool.id, page: page}, params).then (comments)->
        $scope.comments = comments
        $scope.commentTotalItems = comments.$totalItems

    $scope.setTool = (tool) ->
      if $scope.trial
        $scope.question = undefined
        $scope.tool = tool
        AccountProduct.$get("/api/accounts/#{$scope.trial.account_id}/products/#{tool.id}?trial_id=#{$scope.trial.id}").then (product)->
          angular.extend($scope.tool, product)
        $scope.orderingObject = {}
        $scope.results_page = 1
        loadResults()

    $scope.selectQuestion = (header)->
      return if !$scope.tool
      $scope.question = header.options.question
      $scope.comment_page = 1
      $scope.setMode('comments')
      loadComments()

    $scope.$on 'loadResults', ->
      loadResults()

    $rootScope.$on 'selectProduct', (event, data) ->
      $scope.setTool(data)

    $scope.resultsSelectPage = (page)->
      loadResults(page)

    $scope.commentsSelectPage = (page)->
      loadComments(page)

    $scope.formatedValue = (val)->
      if val.options.id == 'date'
        return moment(new Date(val.value)).format('MM/DD/YYYY')
      val.value

    $scope.backToAllProducts = ->
      $scope.setMode('results')
      $scope.question = undefined
      $scope.tool = undefined
      $scope.productSummary = false

    $scope.backToProduct = () ->
      $scope.setMode('results')
      $scope.question = undefined

    model.$render = ()->
      $scope.trial = model.$viewValue
      if $scope.trial
        loadResults()

    watchFunction = (newValue)->
      if newValue && newValue.key
        loadResults()

    $scope.$watch('orderingObject', watchFunction, true)
