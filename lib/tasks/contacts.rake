namespace :app do
namespace :contacts do

	task :import_contacts_from_icf => :environment do
#		raise "This task has been run and disabled."
		icf_data_source_id = DataSource[:icf].id
		unknown_phone_type_id = PhoneType[:unknown].id
		unknown_address_type_id = AddressType[:unknown].id
		CSV.open( 'ln_for_addressupdate_08192013.csv',
				'rb',{ :headers => true }).each do |line|

			#Fullname,Street,Unit,City,State,Zip,
			#	New_Street,New_Unit,New_City,New_State,New_Zipcode,
			#	New_Phone1,New_Phone2,New_Phone3,New_Phone4,New_Phone5,Subjectid

			puts line
			subjects = StudySubject.with_subjectid(line['Subjectid'].to_i)
			raise "Multiple subjects with subjectid #{line['Subjectid']}" if subjects.length > 1
			raise "No subjects with subjectid #{line['Subjectid']}" if subjects.length < 1
			subject = subjects.first

			phone_columns = %w( New_Phone1 New_Phone2 New_Phone3 New_Phone4 New_Phone5 )
			new_phone_numbers = phone_columns.collect{|c| line[c] }.delete_if(&:blank?)
			unless new_phone_numbers.empty?
				subject.phone_numbers.update_all(
					:current_phone => YNDK[:no],:is_primary => false)
				is_primary = true	#	only the first one
				new_phone_numbers.each do |phone_number|
					p = subject.phone_numbers.new(
						:current_phone => YNDK[:yes],
						:is_primary => is_primary,
						:data_source_id => icf_data_source_id,
						:phone_type_id => unknown_phone_type_id,
						:phone_number => phone_number)
					p.save!
					puts p.inspect
					is_primary = false	#	only the first one is true
				end
			end

			address_columns = %w( New_Street New_Unit New_City New_State New_Zipcode )
			if address_columns.collect{|c|line[c].present?}.any?
				unless line['New_Street'].present? && line['New_City'].present? && 
						line['New_State'].present? && line['New_Zipcode'].present?
					puts line
					raise "Something's missing"
				else
					subject.addressings.update_all(:current_address => YNDK[:no])

					new_street = line['New_Street'].squish.namerize
					new_street.gsub!(/^Po Box/, 'PO Box')

					#		This won't matter as is not residence
					#		:subject_moved => 'true',	#	yes, the string 'true', not true
					#		also, this is meant for use when address is marked as not current
					a = subject.addressings.new(
						:current_address => YNDK[:yes],
						:data_source_id => icf_data_source_id,
						:address_attributes => {
							:address_type_id => unknown_address_type_id,
							:line_1 => new_street,
							:unit => line['New_Unit'].namerize,
							:city => line['New_City'].namerize,
							:state => line['New_State'],
							:zip => line['New_Zipcode']
						}
					)
					a.save!
					puts a.inspect
					puts a.address.inspect
				end
			end

		end
#		Sunspot.commit
	end

end	#	namespace :contacts do
end	#	namespace :app do
