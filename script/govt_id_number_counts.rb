#!/usr/bin/env rails runner


puts "All Birth Data Records count: #{BirthDatum.count}"
puts "Case Birth Data Records count: #{BirthDatum.where(:case_control_flag => 1).count}"


%w( do_not_use_local_registrar_no do_not_use_state_registrar_no do_not_use_derived_local_file_no_last6 do_not_use_derived_state_file_no_last6 ).each do |field|
	#	'', '  ' , '    ' are all the same.  Number of spaces doesn't seem to matter
	count = BirthDatum.where(:case_control_flag => 1).where(BirthDatum.arel_table[field].eq_any([nil,'  '])).count	
	puts "Case Birth Data Records with empty #{field} count: #{count}"
end

puts "All Study Subjects count: #{StudySubject.count}"
puts "Case Study Subjects count: #{StudySubject.cases.count}"

%w( do_not_use_state_id_no do_not_use_state_registrar_no local_registrar_no ).each do |field|
	count = StudySubject.cases.where(StudySubject.arel_table[field].eq_any([nil,'  '])).count
	puts "Case Study Subjects with empty #{field} count: #{count}"
end
