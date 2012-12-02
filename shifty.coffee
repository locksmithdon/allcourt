Volunteers = new Meteor.Collection 'volunteers'
Tournaments = new Meteor.Collection 'tournaments'

Meteor.startup ->
  if Meteor.isClient
    filepicker.setKey 'AOu8DnUQ3Tm6caoisKdpnz'

Meteor.methods {
  saveVolunteer: (options) ->
    return Volunteers.insert {
      firstname: options.firstname,
      lastname: options.lastname,
      address: options.address,
      suburb: options.suburb,
      postalcode: options.postalcode,
      email: options.email,
      homephone: options.homephone,
      workphone: options.workphone,
      mobilephone: options.mobilephone,
      birthdate: options.birthdate,
      notes: options.notes,
      asbshirtsize: options.asbshirtsize,
      heinekenshirtsize: options.heinekenshirtsize,
      photo: options.photo
    }
  saveTournament: (options, callback) ->
    return Tournaments.insert {
      tournamentName: options.tournamentName,
      firstDay: options.firstDay,
      lastDay: options.lastDay,
      days: options.days || [],
      roles: options.roles || []
    }, callback
}