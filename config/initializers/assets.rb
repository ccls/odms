# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )


#	20150320 - It is stupid that I have to list my js and css here AGAIN!

#	AND any gem js and css

Rails.application.config.assets.precompile += %w( 
	consent.js
	edit_address.js
	edit_event.js
	edit_patient.js
	edit_phone_number.js
	edit_sample.js
	edit_study_subject.js
	enrolls.js
	jquery.2.0.0.min.js
	jquery-ui.1.10.3.min.js
	jquery-ui.1.10.1.css
	jquery-ui-timepicker-addon.js
	jquery.simplemodal.1.4.4.min.js
	new_address.js
	pages.js
	raf.js
	swfobject.js
	menus.css.scss
	scaffold.css
	simple_modal_basic.css
	sunspot.css sunspot.js
)
