initializeControls = ->
  $('#birthdate').datepicker format: 'dd M yyyy', autoclose: true

createEmailAddress = ->
  firstName = $('#firstName').val()
  lastName = $('#lastName').val()
  name = emailHelper.prepareName firstName, lastName
  name + emailHelper.addressSuffix

getActiveVolunteer = ->
  id = Session.get('active-user')._id
  volunteer = Volunteers.findOne id
  Session.set 'active-volunteer', volunteer
  volunteer

getUserFormValues = (template) ->
  values =
    firstName: template.find('#firstName').value
    lastName: template.find('#lastName').value
    email: template.find('#email')?.value || createEmailAddress()
    photoFilename: template.find('#photoFilename').value
    admin: if template.find('#siteAdmin:checked') then true else false
    proxy: if template.find('#proxy:checked') then true else false
    isNew: if template.find('#isNew:checked') then true else false
    gender: template.find('input:radio[name=gender]:checked').value

getVolunteerFormValues = (template) ->
  values =
    shirtSize: template.find('#shirtSize').value
    birthdate: template.find('#birthdate').value
    homePhone: template.find('#homePhone').value
    mobilePhone: template.find('#mobilePhone').value
    address: template.find('#address').value
    suburb: template.find('#suburb').value
    city: template.find('#city').value
    postalCode: template.find('#postalCode').value
    tennisClub: template.find('#tennisClub').value
    notes: template.find('#notes').value

showSuccess = (msg) ->
  Template.userMessages.showMessage
    type: 'info',
    title: 'Success!',
    message: msg

showError = (msg, err) ->
  Template.userMessages.showMessage
    type: 'error',
    title: 'Uh oh!',
    message: msg + ' Reason: ' + err.reason

showResultOfVolunteerCreation = (err) ->
  if err
    showError 'The new volunteer was not saved.', err
  else
    showSuccess 'The new volunteer was saved successfully.'

showResultOfVolunteerUpdate = (err) ->
  if err
    showError 'The volunteer was not updated.', err
  else
    showSuccess 'The volunteer was updated successfully.'

showResultOfUserCreation = (err) ->
  if err
    showError 'The new user was not saved.', err
  else
    showSuccess 'The new user was saved successfully.'

showResultOfUserUpdate = (err) ->
  if err
    showError 'The user was not updated.', err
  else
    showSuccess 'The user was updated successfully.'

navigateToUserListing = ->
  Router.go 'users'

navigateToUserDetails = ->
  Router.go 'userDetails', userSlug: Session.get('active-user').profile.slug

saveNewUser = (userOptions) ->
  Meteor.call 'createNewUser', userOptions, (err, id) ->
    showResultOfUserCreation err
    navigateToUserListing()

updateUserAndVolunteer = (userOptions, volunteerOptions) ->
  userOptions._id = volunteerOptions._id = Session.get('active-user')._id
  Meteor.call 'updateUser', userOptions, (err) ->
    showResultOfUserUpdate err
    unless err
      Meteor.call 'updateVolunteer', volunteerOptions, (vErr) ->
        showResultOfVolunteerUpdate vErr
        navigateToUserDetails()


Template.userCreate.rendered = ->
  initializeControls()
  user = Session.get 'active-user'
  if user?.profile.photoFilename
    $('.photo-placeholder').removeClass 'empty'

Template.userCreate.userDetails = ->
  details = {}
  user = Session.get('active-user')
  unless user then return proxied: true
  profile = user.profile
  details.email = profile.email
  details.isMale = profile.gender is 'male'
  details.isFemale = profile.gender is 'female'
  $.extend details, profile
  if profile.photoFilename
    details.photoPath = photoHelper.photoRoot + profile.photoFilename
  details.isAdmin = Roles.userIsInRole user, 'admin'
  details.proxy = Roles.userIsInRole user, 'proxy'
  details.isNew = profile.isNew
  # change this to: profile.addedBy isnt user._id
  details.proxied = profile.email.indexOf(emailHelper.addressSuffix) > 1
  details

Template.userCreate.isSelected = (value, constant) ->
  value == constant

Template.userCreate.volunteerDetails = ->
  Session.get('active-volunteer') or { 'hidden': 'hidden' }

Template.userCreate.events
  'click #pickPhoto': (evnt, template) ->
    photoHelper.processPhoto()

  'click #birthdateIcon': (evnt, template) ->
    $('#birthdate').datepicker 'show'

  'click #saveProfile': (event, template) ->
    activeUser = Session.get('active-user')
    userOptions = getUserFormValues template
    volunteerOptions = getVolunteerFormValues template
    if activeUser # edit existing user
      userOptions._id = activeUser._id
      updateUserAndVolunteer userOptions, volunteerOptions
    else # add new user
      saveNewUser userOptions

  'change #femaleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('male').addClass('female')

  'change #maleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('female').addClass('male')
