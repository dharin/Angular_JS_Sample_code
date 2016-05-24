angular.module('SampleCode.factories').factory 'AccountAdmin', (railsResourceFactory)->
  AccountAdmin = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/admins/{{id}}'
    name: 'account_admin'
  })

  AccountAdmin.getAdmins =(accountId)->
    AccountAdmin.query({}, {account_id: accountId})

  AccountAdmin.remove =->
    AccountAdmin.$delete(AccountAdmin.resourceUrl())

  AccountAdmin
