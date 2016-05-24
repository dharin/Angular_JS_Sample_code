angular.module('SampleCode.factories').factory 'AccountOrganization', (railsResourceFactory)->
  AccountOrganization = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/organizations/{{id}}'
    name: 'account_organization'
  })

  AccountOrganization.interceptResponse (response, constructor, context) ->
    if angular.isArray(response.data) and angular.isDefined(response.originalData.count)
      response.data.$totalItems = response.headers().totalitems
    response

  AccountOrganization
