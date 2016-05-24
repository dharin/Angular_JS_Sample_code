angular.module('SampleCode.factories').factory 'TrialSurveys', (railsResourceFactory)->
  TrialSurveys = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/trials/{{trial_id}}/surveys'
    name: 'trial_surveys'
  })

  TrialSurveys
