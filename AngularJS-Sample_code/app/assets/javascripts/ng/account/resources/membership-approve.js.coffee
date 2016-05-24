angular.module('SampleCode.factories').factory 'MembershipApprove', (railsResourceFactory)->
  MembershipApprove = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/admins/{{admin_id}}/membership_approve'
    name: 'membership_approve'
  })

  MembershipApprove
