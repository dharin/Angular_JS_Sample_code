angular.module('SampleCode.factories').factory 'TrialQuestion', (railsResourceFactory)->
  TrialQuestion = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/trials/{{trial_id}}/questions'
  })
  TrialQuestion
