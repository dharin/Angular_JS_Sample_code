angular.module('SampleCode.factories').factory 'Results', (railsResourceFactory)->
  Results = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/trials/{{trial_id}}/results'
    name: 'results'
  })

  Results
