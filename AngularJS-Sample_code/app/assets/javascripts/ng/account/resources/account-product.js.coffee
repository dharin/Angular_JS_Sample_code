angular.module('SampleCode.factories').factory 'AccountProduct', (railsResourceFactory)->
  AccountProduct = railsResourceFactory({
    url: '/api/accounts/{{account_id}}/products'
    name: 'account_product'
  })

  AccountProduct.interceptResponse (response, constructor, context) ->
    if angular.isArray(response.data) and angular.isDefined(response.originalData.count)
      response.data.$totalItems = response.headers().totalitems
    response

  AccountProduct
