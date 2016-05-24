angular.module('SampleCode.directives').directive 'surveyQuestions', ->
  restrict: 'C'
  require: 'ngModel'
  scope: { }
  templateUrl: 'account/survey-questions.html'
  link: ($scope, element, attrs, model)->

    $scope.addQuestion = ->
      $scope.survey_questions.push({})

    $scope.toggleAnswerOptions= (surveyQuestion)->
      surveyQuestion.hideOptions = !surveyQuestion.hideOptions

    $scope.remove = (question)->
      if question.id
        question._destroy = 1
      else
        $scope.survey_questions.remove(question)

    updateNgModel = ->
      index = 0
      for survey_question in $scope.survey_questions
        survey_question.sort_order = index++ unless survey_question._destroy == 1
      model.$setViewValue($scope.survey_questions)

    viewValue = ->
      model.$viewValue

    $scope.$watch viewValue, (newValue)->
      if newValue == undefined
        $scope.survey_questions = []
      else
        $scope.survey_questions = newValue

    $scope.dragStart = (e, ui) ->
      ui.item.data 'start', ui.item.index()
      return

    $scope.dragEnd = (e, ui) ->
      start = ui.item.data('start')
      end = ui.item.index()
      $scope.survey_questions.splice end, 0, $scope.survey_questions.splice(start, 1)[0]
      $scope.$apply()

    sortableEle = $('#sortable-survey-questions').sortable(
      handle: '.handle'
      start: $scope.dragStart
      update: $scope.dragEnd
      )


    $scope.$watch('survey_questions', updateNgModel ,true)

