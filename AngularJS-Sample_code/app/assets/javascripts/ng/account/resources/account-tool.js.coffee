angular.module('SampleCode.factories').factory 'AccountTool', (railsResourceFactory, $http)->
  AccountTool = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/tools/{{id}}'
    name: 'account_tool'
  })

  AccountTool.prototype.sendContactUsers =(params)->
    $http.post(AccountTool.resourceUrl({
      account_id: this.account_id,
      id: this.id
    }) + '/contact_users', params)

  AccountTool.prototype.sendRequestFeedback =(params)->
    $http.post(AccountTool.resourceUrl({
      account_id: this.account_id,
      id: this.id
    }) + '/request_feedback', params)

  AccountTool.prototype.save =(params)->
    AccountTool.$put(AccountTool.resourceUrl({
      account_id: this.account_id,
      id: this.id
    }), params)

  AccountTool.interceptResponse (response, constructor, context) ->
    if angular.isArray(response.data) and angular.isDefined(response.originalData.count)
      response.data.$totalItems = response.headers().totalitems
    response

  AccountTool
