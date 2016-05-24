angular.module('SampleCode.factories').factory 'Trial', (railsResourceFactory, railsSerializer)->
  Trial = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/trials/{{id}}'
    name: 'trial'
    serializer: railsSerializer ->
      this.nestedAttribute('target_criteria')
      this.nestedAttribute('survey_questions')
  })

  Trial::isLoading = ->
    false

  handleDate = (date)->
    if date
      return new Date(date.replace('-','/'))

  Trial::fromDate = ->
    if @start_date
      moment(handleDate(@start_date)).format('MM/DD')
    else
      '--'

  Trial::toDate = ->
    if @end_date
      moment(handleDate(@end_date)).format('MM/DD')
    else
      '--'

  Trial::restricted_by_dates = ->
    @start_date && @end_date

  Trial::periodDefined = ->
    @start_date && @end_date

  Trial::shortPeriod = ->
    if @.periodDefined()
      moment(handleDate(@start_date)).format('MM/DD') + ' - ' + moment(handleDate(@end_date)).format('MM/DD')
    else
      '-'

  Trial::period = ->
    moment(handleDate(@start_date)).format('MM/DD/YYYY') + ' - ' + moment(handleDate(@end_date)).format('MM/DD/YYYY')

  Trial::start_date_display = ->
    moment(handleDate(@created_at)).format('MM/DD/YYYY')

  Trial.prototype.update =(params)->
    Trial.$put(Trial.resourceUrl({
      account_id: this.account_id,
      id: this.id
    }), params)

  Trial.interceptResponse (response, constructor, context) ->
    response

  Trial
