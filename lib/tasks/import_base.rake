#
#	This seems to isolate the code by defining it at the task level.
#
namespace :app do
	#
	#	This task doesn't do anything.  Just kind of an abstract task.
	#
	task :import_base => :environment do
		require 'chronic'

		#
		#	The purpose of these tasks is to import data extracted from the previous
		#	database tables.  THEY ARE DESTRUCTIVE!
		#
		#	This collection of rake tasks will only be used once.  After its successful 
		#	initial usage, I will comment it all out rather than destroy it so that it 
		#	can be referenced.  
		#

#		BASEDIR = "/Volumes/BUF-Fileshare/SharedFiles/SoftwareDevelopment\(TBD\)/GrantApp/DataMigration/20120605b"
#		SUBJECTS_CSV = "#{BASEDIR}/ODMS_SubjectData_Combined_xxxxxx.csv"
#		ADDRESSES_CSV = "#{BASEDIR}/ODMS_Addresses_xxxxxx.csv"
#		ADDRESSINGS_CSV = "#{BASEDIR}/ODMS_Addressings_xxxxxx.csv"
#		PHONENUMBERS_CSV = "#{BASEDIR}/ODMS_Phone_Numbers_xxxxxx.csv"
#		EVENTS_CSV = "#{BASEDIR}/ODMS_Operational_Events_xxxxxx.csv"
#		ICFMASTERIDS_CSV = "#{BASEDIR}/export_ODMS_ICF_Master_IDs.csv"
#		ENROLLMENTS_CSV = "#{BASEDIR}/ODMS_Enrollments_xxxxxx.csv"
#		SAMPLES_CSV = "#{BASEDIR}/ODMS_samples_xxxxxx.csv"
#		ABSTRACTS_CSV = "#{BASEDIR}/ODMS_Abstracts_xxxxxx.csv"

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


		def assert_equal(a,b,field)
			classes = [a,b].collect(&:class)
puts classes
			if( [a,b].any?{|x| x.is_a?(Date) })
				assert_date_equal(a,b,field)
			elsif( [a,b].any?{|x| x.is_a?(DateTime) ||
						x.is_a?(ActiveSupport::TimeWithZone) 
				} )
				assert_datetime_equal(a,b,field)
			elsif( [a,b].any?{|x| x.is_a?(FalseClass) or x.is_a?(TrueClass) } ) 
#	TODO
#puts "-#{a}-#{b}-"
#				assert_string_equal( (a) ? true : false , (b) ? true : false, field)

				puts "Converting #{a} and #{b}"
				new_a = if( [NilClass,FalseClass,TrueClass].include?( a.class ) )
					a
				else
					( a.to_i == 1 )
				end
				new_b = if( [NilClass,FalseClass,TrueClass].include?( b.class ) )
					b
				else
					( b.to_i == 1 )
				end
				puts "Comparing #{new_a} to #{new_b}"
				assert_string_equal(new_a,new_b,field)

			elsif( [a,b].any?{|x| x.is_a?(BigDecimal) or x.is_a?(Fixnum) })
				#	to_f will add a '.0' to an 'integer'
				assert_string_equal(a.to_f, b.to_f, field)
			else
				assert_string_equal(a,b,field)
			end
		end

		def assert_datetime_equal(a,b,field)
#			assert_string_equal a.to_s.to_datetime.try(:strftime,"%m/%d/%Y %H:%M:%S"), b.to_s.to_datetime.try(:strftime,"%m/%d/%Y %H:%M:%S"), field
			assert_string_equal Time.parse(a.to_s).try(:strftime,"%m/%d/%Y %H:%M:%S"), Time.parse(b.to_s).try(:strftime,"%m/%d/%Y %H:%M:%S"), field
		end

		def assert_date_equal(a,b,field)
			assert_string_equal a.to_s.to_date.try(:strftime,"%m/%d/%Y"), b.to_s.to_date.try(:strftime,"%m/%d/%Y"), field
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

	end	#	task :import_base => :environment do

end	#	namespace :app do
