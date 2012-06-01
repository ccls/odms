#
#	This seems to isolate the code by defining it at the task level.
#
namespace :odms_import do
	#
	#	This task doesn't do anything.  Just kind of an abstract task.
	#
	task :odms_import_base => :environment do
		require 'fastercsv'
		require 'chronic'

		#
		#	The purpose of these tasks is to import data extracted from the previous
		#	database tables.  THEY ARE DESTRUCTIVE!
		#
		#	This collection of rake tasks will only be used once.  After its successful 
		#	initial usage, I will comment it all out rather than destroy it so that it 
		#	can be referenced.  
		#

#		BASEDIR = "/Volumes/BUF-Fileshare/SharedFiles/SoftwareDevelopment\(TBD\)/GrantApp/DataMigration/"
		BASEDIR = "/Volumes/BUF-Fileshare/SharedFiles/SoftwareDevelopment\(TBD\)/GrantApp/DataMigration/20120517/"
		SUBJECTS_CSV = "#{BASEDIR}/ODMS_SubjectData_Combined_xxxxxx.csv"
		ADDRESSES_CSV = "#{BASEDIR}/ODMS_Addresses_xxxxxx.csv"
		ADDRESSINGS_CSV = "#{BASEDIR}/ODMS_Addressings_xxxxxx.csv"
		PHONENUMBERS_CSV = "#{BASEDIR}/ODMS_Phone_Numbers_xxxxxx.csv"
		EVENTS_CSV = "#{BASEDIR}/ODMS_Operational_Events_xxxxxx.csv"
		ICFMASTERIDS_CSV = "#{BASEDIR}/export_ODMS_ICF_Master_IDs.csv"
		ENROLLMENTS_CSV = "#{BASEDIR}/ODMS_Enrollments_xxxxxx.csv"
		SAMPLES_CSV = "#{BASEDIR}/ODMS_samples_xxxxxx.csv"
		ABSTRACTS_CSV = "#{BASEDIR}/ODMS_Abstracts_xxxxxx.csv"

		def format_date(date)
			( date.blank? ) ? nil : date.try(:strftime,"%m/%d/%Y")
		end

		def format_time_to_date(time)
			( time.blank? ) ? nil : format_date(Time.parse(time).to_date)
		end

		#	gonna start asserting that everything is as expected.
		#	will slow down import, but I want to make sure I get it right.
		def assert(expression,message = 'Assertion failed.')
			raise "#{message} :\n #{caller[0]}" unless expression
		end

		def assert_string_equal(a,b,field)
			assert a.to_s == b.to_s, "#{field} mismatch:#{a}:#{b}:"
		end

		#	Object and not String because could be NilClass
		Object.class_eval do

			def nilify_blank
				( self.blank? ) ? nil : self
			end

			def to_nil_or_boolean
				if self.blank?
					nil
				else
					( self.to_i == 1 or self.to_s.upcase == 'TRUE' ) ? true : false
				end
			end

			def to_nil_or_yndk
				if self.blank?
					nil
				else
					( self.upcase == 'TRUE' ) ? YNDK[:yes] : YNDK[:no]
				end
			end

			def to_nil_or_i
				( self.blank? ) ? nil : self.to_i
			end

			def to_nil_or_time
				( self.blank? ) ? nil : Time.parse(self)
			end

			def to_nil_or_date
				( self.blank? ) ? nil : Time.parse(self).to_date
			end

			#	this is only used for a missing organization_id
		#	def to_dk_or_i
		#		( self.blank? ) ? 9999999 : self.to_i
		#	end

			def only_numeric
				self.to_s.gsub(/\D/,'')
			end

			def to_nil_or_999_or_i
				if self.blank?
					nil
				else
					if self.to_s == '9'
						999
					else
						self.to_i
					end
				end
			end

		end	#	Object.class_eval do

	end	#	task :odms_import_base => :environment do

end	#	namespace :odms_import do
