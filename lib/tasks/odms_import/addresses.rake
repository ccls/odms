require 'tasks/odms_import/base'

namespace :odms_import do

	desc "Import data from addresses csv file"
	task :addresses => :odms_import_base do 
		puts "Destroying addresses"
		Address.destroy_all
		puts "Importing addresses"

		error_file = File.open('addresses_errors.txt','w')	#	overwrite existing

		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=FasterCSV.open(ADDRESSES_CSV, 'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}"
			puts line

#"address_type_id","data_source_id","line_1","unit","city","state","zip","external_address_id","county","country","created_at"

#	TODO convert this to block creation. Why?
			address = Address.create({
				:address_type_id => line["address_type_id"],
				:data_source_id  => line["data_source_id"],
				:line_1          => line["line_1"],
				:unit            => line["unit"],
				:city            => line["city"],
				:state           => line["state"],
				:zip             => line["zip"],
				:external_address_id => line["external_address_id"],
				:county          => line["county"],
				:country         => line["country"],
				:created_at      => (( line['created_at'].blank? ) ?
														nil : Time.parse(line['created_at']) )
			})

			if address.new_record?
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: #{address.errors.full_messages.to_sentence}"
				error_file.puts line
				error_file.puts
			else
				address.reload
				assert address.address_type_id == line["address_type_id"].to_nil_or_i,
					'Address Type mismatch'
				assert address.data_source_id  == line["data_source_id"].to_nil_or_i,
					'Data Source mismatch'
				assert address.line_1          == line["line_1"],
					'Line 1 mismatch'
				assert address.line_2.blank?
					'Line 2 mismatch'
				assert address.unit            == line["unit"],
					'Unit mismatch'
				assert address.city            == line["city"],
					'City mismatch'
				assert address.state           == line["state"],
					'State mismatch'
				assert address.zip.only_numeric == line["zip"].only_numeric,
					'Zip mismatch'
				assert address.external_address_id == line["external_address_id"].to_nil_or_i,
					'External Address mismatch'
				assert address.county          == line["county"],
					'County mismatch'
				assert address.country         == line["country"],
					'Country mismatch'
			end

		end
		error_file.close
	end

end
