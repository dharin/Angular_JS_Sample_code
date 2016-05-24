angular.module('SampleCode.directives').directive 'accountTools', (
  paginatedResource, AccountTool, AccountOrganization, OrganizationTool
  searchResources, $window, $modal)->

  restrict: 'A'
  require: 'ngModel'
  scope: {}
  templateUrl: 'account/tools.html'
  link: ($scope, element, attrs, model)->

    $scope.subject = ""
    $scope.customMessage = ""
    $scope.modalInstance = null
    $scope.currentView = 'all_tools'
    $scope.isGeneratingExport = false

    loadTools =(accountId)->
      queryParameters = { per_page: 20 }
      angular.extend(queryParameters, { status: 'unknown'}) if $scope.currentView == 'exception_tools'

      # paginatedResource.apply($scope, AccountTool, 'tools',
      #       additionalParameters: { account_id: accountId },
      #       queryParameters: queryParameters)

      paginatedResource.apply($scope, OrganizationTool, 'tools',
            additionalParameters: { organization_id: 26, organization_type: 'School' },
            queryParameters: queryParameters)

    # to know how many tools there are
    $scope.$watch('toolsTotalItems', (newValue, oldValue)->
      if newValue && $scope.$parent.toolsTotalItems == undefined
        $scope.$parent.toolsTotalItems = newValue
    )


    $scope.showRequestFeedbackModal = (tool) ->
      $scope.tool = tool
      $scope.modalInstance = $modal.open(
        templateUrl: 'request-feedback-modal.html'
        scope: $scope
        size: 'sm'
      )
      $scope.modalInstance.result.then ->
        window.location.reload()

    $scope.showCustomMessageModal = (tool) ->
      $scope.tool = tool
      $scope.modalInstance = $modal.open(
        templateUrl: 'contact-users-modal.html'
        scope: $scope
        size: 'sm'
      )
      $scope.modalInstance.result.then ->
        window.location.reload()

    $scope.requestFeedback = (tool, messageSubject, messageBody) ->
      accountTool = new AccountTool({ id: tool.id, account_id: $scope.account_id })
      accountTool.sendRequestFeedback({ messageSubject: messageSubject, messageBody: messageBody }).then(->
        $scope.modalInstance.dismiss('cancel')
      )

    $scope.sendCustomMessage = (tool, messageSubject, messageBody) ->
      accountTool = new AccountTool({ id: tool.id, account_id: $scope.account_id })
      accountTool.sendContactUsers({ messageSubject: messageSubject, messageBody: messageBody }).then(->
        $scope.modalInstance.dismiss('cancel')
      )
      

    newQuote =->
      {
        item_type: 'license'
        description: ''
        cost: 0
        unit: 'student'
        period: 'time'
        quantity: 0
        new: true
      }

    # operations to calculate the quote
    quoteCalculation =(tool)->
      tool.periodCost =(period, unit)->
        sum = 0
        $.each(this.line_items, (index, item)->
          if item.period == period && item.unit == unit
            sum += (item.cost * item.quantity)
        )
        sum

      tool.periodCostByUnit =(period, unit)->
        cost = this.periodCost(period, unit)
        numberUnits = 0
        $.each(this.line_items, (index, item)->
          if item.period == period && item.unit == unit
            numberUnits += item.quantity
        )
        cost / numberUnits

      tool.cost =(years, unit)->
        oneTime = this.periodCost('time', unit)
        annual = this.periodCost('year', unit) * years
        oneTime + annual

      tool.costByUnit =(years, unit)->
        oneTime = this.cost(years, unit)
        # sum all unit
        numberUnits = 0
        $.each(this.line_items, (index, item)->
          if item.unit == unit
            numberUnits += item.quantity
        )
        oneTime / numberUnits

    model.$render = ->
      $scope.account_id = model.$viewValue
      $scope.showAddProduct = false
      $scope.tool = null

      if $scope.account_id
        # both avoid the first request to searchResources tools
        $scope.term = undefined
        initializedTermTool = false

        loadTools($scope.account_id)
        # initialize search resource just when user try to find tools
        $scope.$watch('term', ->
          if $scope.term != undefined && !initializedTermTool
            searchResources.apply($scope, 'term', $scope.toolsReloadItems)
            initializedTermTool = true
        )

    $scope.changeToolView = (view) ->
      console.info('changeToolView')
      if view != $scope.currentView
        $scope.currentView = view
        loadTools($scope.account_id)

    # on add a tool to my portfolio
    $scope.$on('onAddToolSelect', (event, tool) ->
      $scope.$parent.toolsTotalItems = undefined
      new AccountTool({
        account_id: $scope.account_id
        tool_id: tool.id
      }).create().then ((data) ->
        loadTools($scope.account_id)
      ),(response) ->
        $scope.$parent.showErrorMsg = true
        if response.status == 409
          $scope.$parent.errorMsg = "Tool already added to the organization"
        else
          $scope.$parent.errorMsg = "There was an error adding the tool"
    )

    $scope.onNoLongerUseIt = (organization_tool)->
      console.info(tool)
      console.info($scope)
      new OrganizationTool({
        id: organization_tool.organization_tool_id
        organization_id: $scope.accountable_id
        organization_type: $scope.accountable_type
      }).remove().then ((data) ->
        loadTools($scope.account_id)
      ),(response) ->
        $scope.$parent.errorMsg = "There was an error removing the tool"
        $scope.$parent.showErrorMsg = true

    $scope.onShowAddProduct =(show)->
      $scope.showAddProduct = show



    $scope.onCancelModal =->
      $scope.modalInstance.dismiss('cancel')

    $scope.exportPortfolio =->
      $scope.isGeneratingExport = true
      AccountTool.$get("/accounts/#{$scope.account_id}/tools/pdf").then (data)->
        $scope.isGeneratingExport = false
        window.open(data.url, '_blank');

    $scope.onRequestQuote =(tool)->
      # initialize the operations to calculate
      quoteCalculation(tool)
      tool.showRequestQuote = true
      # new quote if there are not
      tool.line_items.push(newQuote()) if tool.line_items.length == 0

    $scope.onAddQuote =(tool)->
      tool.line_items.push(newQuote())

    $scope.onRemoveQuote =(tool, quote)->
      if quote.new == false
        quote._destroy = true
      else
        tool.line_items.remove(quote)

      # create new item if there are not
      items = $.grep(tool.line_items, (item)-> item._destroy == false || item._destroy == undefined)
      tool.line_items.push(newQuote()) if items.length == 0

    $scope.onEditQuote =(quote)->
      quote.new = true

    $scope.onSaveQuote =(tool)->
      tool.line_items_attributes = tool.line_items
      new AccountTool({
        account_id: $scope.account_id
        id: tool.id
      }).save(tool).then ((response) ->
        tool.showRequestQuote = false
        new AccountTool({
          account_id: $scope.account_id
          id: tool.id
        }).get().then ((item) ->
          tool.line_items = item.line_items
          tool.status = item.status
        )
        loadTools($scope.account_id) if $scope.currentView == 'exception_tools'
      ),(response) ->
        $scope.$parent.errorMsg = "There was an error adding the tool"
        $scope.$parent.showErrorMsg = true

    $scope.onCancelQuote =(tool)->
      tool.showRequestQuote = false

    $scope.filterRemoved =(item)->
      item._destroy == false || item._destroy == undefined

    $scope.calculate
