angular.module('SampleCode.factories').factory 'Account',(railsResourceFactory, railsSerializer)->
  resource = railsResourceFactory({
    url: '/api/accounts',
    name: 'account',
    serializer: railsSerializer ()->
      this.resource('trials', 'Trial')
  })

  resource.prototype.profile =->
    resource.$get(resource.resourceUrl({id: this.id}) + '/profile')

  resource
