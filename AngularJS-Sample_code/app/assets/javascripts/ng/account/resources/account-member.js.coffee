angular.module('SampleCode.factories').factory 'AccountMember', (railsResourceFactory)->
  AccountMember = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/members/{{id}}?parent_organization_type={{parent_organization_type}}&parent_organization_id={{parent_organization_id}}'
    name: 'account_member'
  })

  AccountMember.interceptResponse (response, constructor, context) ->
    if angular.isArray(response.data) and angular.isDefined(response.originalData.count)
      response.data.$totalItems = response.headers().totalitems
    response

  AccountMember.prototype.approve =->
    AccountMember.$post("/api/accounts/#{this.account_id}/members/#{this.id}/approve")

  AccountMember.prototype.reject =->
    AccountMember.$post("/api/accounts/#{this.account_id}/members/#{this.id}/reject")

  AccountMember
