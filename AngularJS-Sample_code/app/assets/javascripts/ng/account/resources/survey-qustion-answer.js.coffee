angular.module('SampleCode.factories').factory 'SurveyQuestionAnwer', (railsResourceFactory)->
  SurveyQuestionAnwer = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/trials/{{trial_id}}/survey_question_answers'
  })

  SurveyQuestionAnwer.interceptResponse (response, constructor, context) ->
    if angular.isArray(response.data) and angular.isDefined(response.originalData.count)
      response.data.$totalItems = response.headers().totalitems
    response

  SurveyQuestionAnwer
