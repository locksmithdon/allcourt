@userSearch = new Meteor.Stream 'userSearch'

if Meteor.isClient
  @submitUserSearch = (query, handler) ->
    userSearch.on Meteor.userId(), handler
    userSearch.emit 'user-search', query

if Meteor.isServer
  userSearch.permissions.write (eventName) ->
    eventName is 'user-search' and this.userId

  userSearch.permissions.read (eventName) ->
    this.userId is eventName

  userSearch.on 'user-search', (query) ->
    results = Registrations.find {}

    userSearch.emit this.userId, results
