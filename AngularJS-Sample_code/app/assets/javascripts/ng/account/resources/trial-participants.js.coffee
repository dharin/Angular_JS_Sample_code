angular.module('SampleCode.factories').factory 'TrialParticipants', (railsResourceFactory)->
  TrialParticipants = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/trials/{{trial_id}}/participants'
  })

  TrialParticipants::gradeDate = ->
    if @survey_created_at
      moment(new Date(@survey_created_at.replace('-','/'))).format('MMM-DD-YYYY')
    else
      ' - '

  TrialParticipants.interceptResponse (response, constructor, context) ->
    if angular.isArray(response.data) and angular.isDefined(response.originalData.count)
      response.data.$totalItems = response.headers().totalitems
    response

  TrialParticipants
