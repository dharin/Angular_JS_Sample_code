angular.module('SampleCode.factories').factory 'AccountMemberOrganization', (railsResourceFactory)->
  AccountMemberOrganization = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/members/organizations?parent_organization_type={{parent_organization_type}}&parent_organization_id={{parent_organization_id}}'
    name: 'account_member_organization'
  })

  AccountMemberOrganization.interceptResponse (response, constructor, context) ->
    if angular.isArray(response.data) and angular.isDefined(response.originalData.count)
      response.data.$totalItems = response.headers().totalitems
    response

  AccountMemberOrganization.prototype.approve =->
    AccountMemberOrganization.$post("/api/accounts/#{this.account_id}/members/#{this.id}/approve")

  AccountMemberOrganization.prototype.reject =->
    AccountMemberOrganization.$post("/api/accounts/#{this.account_id}/members/#{this.id}/reject")

  AccountMemberOrganization
