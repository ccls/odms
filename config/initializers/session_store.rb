# Be sure to restart your server when you modify this file.

#Odms::Application.config.session_store :cookie_store, :key => '_odms_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
Odms::Application.config.session_store :active_record_store


#	In my tests, I see A LOT of ....
#
#	ActiveRecord::StatementInvalid: Mysql2::Error: Field 'session_id' doesn't have a default value: INSERT INTO `sessions` (`created_at`, `data`, `updated_at`) VALUES ('2014-03-13 00:22:04', 'BAh7BkkiDmNhbG5ldHVpZAY6BkVGSSIKVUlENDIGOwBU\n', '2014-03-13 00:22:04')
#	Found this suggestion ...
#		http://stackoverflow.com/questions/19512535/rails-4-activerecordstatementinvalid
#		https://github.com/rails/activerecord-session_store/issues/6
#
ActiveRecord::SessionStore::Session.attr_accessible :data, :session_id

