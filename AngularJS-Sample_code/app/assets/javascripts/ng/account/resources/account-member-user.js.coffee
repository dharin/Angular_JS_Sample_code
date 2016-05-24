angular.module('SampleCode.factories').factory 'AccountMemberUser', (railsResourceFactory)->
  AccountMemberUser = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/members/users?parent_organization_type={{parent_organization_type}}&parent_organization_id={{parent_organization_id}}'
    name: 'account_member_user'
  })

  AccountMemberUser.interceptResponse (response, constructor, context) ->
    if angular.isArray(response.data) and angular.isDefined(response.originalData.count)
      response.data.$totalItems = response.headers().totalitems
    response

  AccountMemberUser.prototype.approve =->
    AccountMemberUser.$post("/api/accounts/#{this.account_id}/members/#{this.id}/approve")

  AccountMemberUser.prototype.reject =->
    AccountMemberUser.$post("/api/accounts/#{this.account_id}/members/#{this.id}/reject")

  AccountMemberUser
