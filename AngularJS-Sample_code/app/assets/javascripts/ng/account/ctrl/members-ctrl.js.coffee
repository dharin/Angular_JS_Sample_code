angular.module('SampleCode.controllers').controller 'MembersCtrl', ($scope, $rootScope, $interval, AccountMember, AccountMemberOrganization, AccountMemberUser, AccountOrganization, Membership, MembershipApprove, paginatedResource, searchResources, $modal, UserApplication)->

  $scope.lastMember = ''

  $scope.init = (account_id, organization_type, organization_id)->
    $scope.account_id = account_id
    $scope.organization_id = organization_id
    $scope.organization_type = organization_type
    $scope.showNotification = false
    $scope.notificationHeader = null
    $scope.notificationMessage = null
    $scope.membershipBreadcrumbs = []
    $scope.currentView = 'organizations'
    $scope.member_search_term = undefined
    $scope.selectedMembership = null

    # determine term to search organization
    $scope.organizationsTerm = undefined
    initializedOrganizationsTerm = false

    $scope.accountTerm = undefined
    initializedAccountTerm = false

    loadMembers()

  loadMembers = ->
    org_id = if $scope.selectedMembership then $scope.selectedMembership.member_id else $scope.organization_id
    org_type = if $scope.selectedMembership then $scope.selectedMembership.member_type else $scope.organization_type

    paginatedResource.resetWatcher('organizationsMemberships')
    paginatedResource.resetWatcher('usersMemberships')
    paginatedResource.apply($scope, Membership, 'organizationsMemberships', { queryParameters: { organization_id: org_id, organization_type: org_type, member_type: 'Organization' } })
    paginatedResource.apply($scope, Membership, 'usersMemberships', { queryParameters: { organization_id: org_id, organization_type: org_type, member_type: 'User' } })

  searchMembers = ->
    searchResources.apply($scope, 'member_search_term', $scope.organizationsMembershipsReloadItems)
    $interval(->
      searchResources.apply($scope, 'member_search_term', $scope.usersMembershipsReloadItems)
    , 200, 1)

  $scope.showMemberProfile = (membership) ->
    modalInstance = $modal.open(
      templateUrl: 'organizations/show.html'
      controller: 'OrganizationShowCtrl'
      windowClass: 'trial-form'
      resolve: {
        organizationId: ->
          membership.member_id
        organizationType: ->
          membership.member_type
        }
    )

  $scope.deleteMembership = (membership)->
    membership.delete().then (results) ->
      $scope.usersMemberships.remove(membership)

  $scope.addMember = ->
    orgType = if $scope.selectedMembership then $scope.selectedMembership.member_type else $scope.organization_type
    orgId = if $scope.selectedMembership then $scope.selectedMembership.member_id else $scope.organization_id
    modalInstance = $modal.open(
      templateUrl: 'memberships/create.html'
      controller: 'createMembershipCtrl'
      resolve: {
        title: ->
          'Add a New Member'
        membership: ->
          new Membership(organization_id: orgId, organization_type: orgType)
      }
    )
    modalInstance.result.then (newMembership)->
      $scope.usersMemberships.unshift(newMembership)

  $scope.uploadMembers = ->
    # orgType = $scope.membershipBreadcrumbs[$scope.membershipBreadcrumbs.length - 1].member_type if $scope.membershipBreadcrumbs[$scope.membershipBreadcrumbs.length - 1] != undefined
    # orgId = $scope.membershipBreadcrumbs[$scope.membershipBreadcrumbs.length - 1].member.id if $scope.membershipBreadcrumbs[$scope.membershipBreadcrumbs.length - 1] != undefined
    orgId = $scope.selectedMembership.member_id if $scope.selectedMembership
    orgType = $scope.selectedMembership.member_type if $scope.selectedMembership

    modalInstance = $modal.open(
      templateUrl: 'account/upload-members.html'
      controller: 'uploadMembersCtrl'
      resolve: {
        accountId: ->
          $scope.account_id
        organizationType:->
          orgType
        organizationId: ->
          orgId
        accountableType: ->
          $scope.organization_type
        accountableId: ->
          $scope.organization_id
      }
    )

  $scope.showOrganizationMembers = (membership) ->
    $scope.selectedMembership = membership

    if membership != null
      $scope.lastMember = membership
      if $scope.membershipBreadcrumbs.indexOf(membership) == -1
        $scope.membershipBreadcrumbs.push membership
    else
      $scope.membershipBreadcrumbs = []
      $scope.lastMember = ''

    $scope.member_search_term = ''
    loadMembers()

  $scope.membershipBreadcrumbSelected = (membership) ->
    index = $scope.membershipBreadcrumbs.indexOf membership
    $scope.membershipBreadcrumbs = $scope.membershipBreadcrumbs.splice(0, index)
    $scope.showOrganizationMembers(membership)
    $scope.currentView = 'organizations'

  $scope.filterMembers =(item)->
    item.member_type == "User" && (item.approved == true || (item.approved == false && item.approved_at == null))

  $scope.onFilterMembers =->
    if $scope.member_search_term == ''
      searchMembers()

  $scope.$watch('member_search_term', ->
    if $scope.member_search_term != undefined
      searchMembers()
  )

  $rootScope.$on 'import_polling', (event, importObj) ->
    $scope.showNotification = true
    if importObj.is_completed
      $scope.notificationHeader = "Import Successful"
      if importObj.error_message != null
        $scope.notificationHeader = "Import Failed"
        $scope.notificationMessage = importObj.error_message
    else
      $scope.notificationHeader = "Import is in Progress..."

  # This section is responsible for setting the correct members tab
  $scope.$watch('selectedMembership', (newValue, oldValue)->
    $scope.selectedMembershipChanged = true
  )

  $scope.$watch('organizationsMembershipsLoading', (newValue, oldValue)->
    $scope.setCurrentView() if !newValue && $scope.selectedMembershipChanged
  )

  $scope.$watch('usersMembershipsLoading', (newValue, oldValue)->
    $scope.setCurrentView() if !newValue && $scope.selectedMembershipChanged
  )

  $scope.hasApplication = (membership)->
    if membership.member
      result = $.grep(membership.member.applications, (application)->
        application.organization_id == $scope.organization_id && application.organization_type == $scope.organization_type
      )
      result.length > 0
    else
      false

  $scope.onViewApplication = (membership)->
    UserApplication.get({
      user_id: membership.member_id
    }, {
      targetable_id: membership.id
      targetable_type: 'Membership'
    }).then (application) ->
      if application.length > 0
        modalInstance = $modal.open(
          templateUrl: 'account/view-submission-application.html'
          controller: 'ViewSubmissionApplicationCtrl'
          windowClass: 'submission-application-modal'
          resolve: {
            applicationTemplate: ->
              undefined
            application: ->
              application[0]
            additionalData: ->
              {}
          }
        )

  $scope.setCurrentView = ->
    if !$scope.organizationsMembershipsLoading && !$scope.usersMembershipsLoading
      if $scope.usersMembershipsTotalItems == 0 && $scope.organizationsMembershipsTotalItems != 0
        $scope.currentView = 'organizations'
      else if $scope.usersMembershipsTotalItems != 0 && $scope.organizationsMembershipsTotalItems == 0
        $scope.currentView = 'educators'
      else if $scope.usersMembershipsTotalItems == 0 && $scope.organizationsMembershipsTotalItems == 0
        $scope.currentView = 'educators'
