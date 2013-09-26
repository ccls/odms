#!/usr/bin/env rails runner

require 'csv'

name_changes = []

#puts OperationalEvent.where(:operational_event_type_id => 28).where(OperationalEvent.arel_table[:notes].matches('Changes%')).count
#584

OperationalEvent.where(:operational_event_type_id => 28).where(OperationalEvent.arel_table[:notes].matches('Changes%')).each do |oe|
#
#	puts oe.description
#	puts oe.notes
#
#
#Changes:  {"father_first_name"=>["Frederico", "Federico"], "father_middle_name"=>[nil, "-"], "father_last_name"=>["Tapia", "Tapai Cortez"], "mother_middle_name"=>[nil, "-"], "mother_maiden_name"=>[nil, "Rangel Ortiz"], "state_registrar_no"=>[nil, "1052004374227"]}
#Birth Record data changes from CLS Cases 25APR2013 -- Batch 2.csv
#
#
	changes = oe.notes.sub(/^Changes: /,'')

#{"dob"=>[Sun, 28 Sep 2003, Fri, 26 Sep 2003]}
#	this won't eval due to the dates.
#	puts changes
	changes.gsub!(/"dob"=>\[.*?\],?/,'')
#	puts changes

	(eval changes).each do |k,v|
		if k.match(/name/)
#			puts "#{k} is a name"

			#	v will be an array of the old value and the new value.  The old could be nil.
			if v.first.to_s.match(/\w \w/)
#				puts "Old value had a space in it"
				name_changes.push({
					:master_id => oe.study_subject.icf_master_id,
					:field     => k,
					:old_value => v[0],
					:new_value => v[1],
					:current => oe.study_subject.send(k)
				})
			end

		end

	end
end


#puts BirthDatum.where(BirthDatum.arel_table[:study_subject_changes].matches('%_name%')).count
#122

BirthDatum.where(BirthDatum.arel_table[:study_subject_changes].matches('%_name%')).each do |bd|

#	eval bd.study_subject_changes
#	=> should yield a hash

#{"father_first_name"=>["Steven Adam", "Steven"], "state_registrar_no"=>[nil, "32108002245"]}
#{"last_name"=>["Cordon", "Cordonlopez"]}
#{"father_first_name"=>["Jesus", "Jesus Amado"], "first_name"=>["Gavriel", "Gavriel Luis"], "middle_name"=>[nil, "Angeles"]}
#{"middle_name"=>[nil, "Amelie"]}
#{"father_last_name"=>[nil, "Macias"], "middle_name"=>[nil, "Lynn"]}
#{"father_first_name"=>[nil, "Daniel"], "father_last_name"=>[nil, "Jue"], "middle_name"=>[nil, "Jue"]}
#{"middle_name"=>["L", "Luismichael"]}

#	puts bd.study_subject_changes

	(eval bd.study_subject_changes).each do |k,v|
		if k.match(/name/)
#			puts "#{k} is a name"

			#	v will be an array of the old value and the new value.  The old could be nil.
			if v.first.to_s.match(/\w \w/)
#				puts "Old value had a space in it"
				name_changes.push({
					:master_id => bd.study_subject.icf_master_id,
					:field     => k,
					:old_value => v[0],
					:new_value => v[1],
					:current => bd.study_subject.send(k)
				})
			end

		end

	end

end

puts name_changes.length
puts name_changes.uniq.length
puts name_changes.sort_by{|h| h[:master_id] }.uniq

outcsv = CSV.open('birth_data_updates_that_may_have_truncated_names.csv','w')
fields = %w( master_id field old_value new_value current )
outcsv << fields
name_changes.sort_by{|h| h[:master_id] }.uniq.each do |s|
	outcsv << fields.collect{|field| s[field.to_sym] }
end
outcsv.close
