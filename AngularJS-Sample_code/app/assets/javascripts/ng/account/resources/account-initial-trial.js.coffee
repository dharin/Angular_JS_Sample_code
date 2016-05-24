angular.module('SampleCode.factories').factory 'AccountInitialTrial', (railsResourceFactory)->
  AccountInitialTrial = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/initial_trial'
    name: 'account_initial_trial'
  })

  AccountInitialTrial
