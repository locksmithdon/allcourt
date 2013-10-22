updateUserProfileWithType = (role) ->
	Meteor.users.update { _id: Meteor.userId() }, { $set: { 'profile.role': role } }, (err) ->
		if err
			Template.userMessages.showMessage
				type: 'error',
				title: 'Profile not updated.',
				message: 'Unexpected error. Please try again and let us know if you keep seeing this.'

createVolunteerDocument = ->
	options = '_id': Meteor.userId()
	Meteor.call 'createNewVolunteer', options, (err) ->
		if err
			Template.userMessages.showMessage
				type: 'error',
				title: 'Unexpected error.'
				message: 'Unable to create the volunteer record associated with your account. Please try again.',

sendConfirmationEmail = ->
	Meteor.call 'sendEmail', {
		from: 'All-Court Registrations <postmaster@allcourt.co.nz>',
		to: [Meteor.user().profile.email, 'Tennis Auckland <volunteers@tennisauckland.co.nz>'],
		replyTo: [Meteor.user().profile.email, 'Tennis Auckland <volunteers@tennisauckland.co.nz>'], 
		bcc: 'locksmithdon@gmail.com',
		subject: 'New user registration on allcourt.co.nz',
		text: "#{Meteor.user().profile.firstName}, thank you for your #{Meteor.user().profile.role} registration at All-Court.\n\nIf you have any questions, just reply to this message and someone from Tennis Auckland will get back to you as soon as they can.\n\nAll-Court is still under development, but in the near future (before the tournaments begin) you'll be able to use it to help with your involvement in the tournaments.\n\nWarm regards,\nTennis Auckland" },
		(err) ->
			if err
				Template.userMessages.showMessage
					type: 'error',
					title: 'Unable to send email.'
					message: 'We were unable to send the confirmation email. Please contact volunteers@tennisauckland.co.nz to ensure your volunteering status is sorted.',


Template.setupNewUser.events

	'click #saveRole': (evnt, template) ->
		role = template.find('#role').value
		if role is 'blank'
			Template.userMessages.showMessage
				type: 'error',
				title: 'Must choose a role.',
				message: 'Please select a role to continue.'
		else
			Session.set 'user-just-added', true
			updateUserProfileWithType role
			if role is 'volunteer'
				createVolunteerDocument()
			sendConfirmationEmail()

	'change #role': (evnt, template) ->
		if template.find('#role').value isnt 'blank'
			Template.userMessages.clear()