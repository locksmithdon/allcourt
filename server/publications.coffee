Meteor.publish null, ->
  return Meteor.users.find {}, fields: username: 1, email: 1, profile: 1

Meteor.publish 'schedule', ->
  return Schedule.find()

Meteor.publish 'volunteers', ->
  return Volunteers.find()

Meteor.publish 'tournaments', ->
  return Tournaments.find()

Meteor.publish 'registrants', ->
  return Registrants.find()

Meteor.publish 'user-list-with-team', (teamId, tournamentId) ->
  criteria = teamId: teamId, tournamentId: tournamentId
  selector = registrations: $elemMatch: criteria
  return Registrations.find selector, sort: fullName: 1

Meteor.publish 'user-list-with-role', (roleId, tournamentId) ->
  criteria = roleId: roleId, tournamentId: tournamentId
  selector = registrations: $elemMatch: criteria
  return Registrations.find selector, sort: fullName: 1
