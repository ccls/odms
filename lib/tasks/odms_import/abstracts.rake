namespace :odms_import do

	desc "Import data from abstracts csv file"
	task :abstracts => :odms_import_base do 
		puts "Destroying abstracts"
		Abstract.destroy_all
		puts "Importing abstracts"

		error_file = File.open('abstracts_errors.txt','w')	#	overwrite existing

		translation_table = {}
		(f=FasterCSV.open("Abst_DB_New_Var_Names_Aug2010.csv",'rb',{ 
			:headers => true })).each do |line|
			next if line['current_field_name'].blank?
			translation_table[line['current_field_name'].upcase] = line['new_field_name']
		end

		f=FasterCSV.open(ABSTRACTS_CSV, 'rb')
		column_names = f.readline
		f.close

#		puts column_names
#		column_names.each do |name|
#			if translation_table[name.upcase]
##				puts "#{name} translates to #{translation_table[name]}"
#				translation_table.delete(name.upcase)
#			else
#				puts "---HELP :#{name}: NOT FOUND"
#			end
#		end
#
#		puts translation_table.inspect
#
#		puts "Translatable keys: #{initial_translation_keys_count}"
#		puts "CSV Columns: #{column_names.length}"

		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
		(f=FasterCSV.open(ABSTRACTS_CSV, 'rb',{ :headers => true })).each do |line|
			puts "Processing line #{f.lineno}"
			puts line

#"ID","ChildID","BMA1","BMA2","BMA3","BMB1","BMB2","BMB3","CBC1","CBC2","CBC3","CBC4","CBC4A","CBC5","CBC6","CBF1","CBF2","CBF3","CBF3b","CBF4","CBF4b","CBF5a","CBF5b","CBF6a","CBF6b","CBF7","CBF7_old","CIM1","CIM2","CIM3","CIM4","CIM5","CIM6","CIM7","CIM8","CC1","CC2","CC4","CC5","CC6","CY1","CY2","CY3","CY3_legacy","CY3AA","CY3A","CY3B","CY3C","CY3D","CY4","CY5","CreateDate","CreatedBy","CY_Tri21_Fish","CY_Tri21_GBand","CY_Tri21_Pheno","CY_Tri21_Pheno_old","CY_Tri4_FISH","CY_Tri4_GBand","CY_Tri10_FISH","CY_Tri10_GBand","CY_Tri17_FISH","CY_Tri17_GBand","CY_Tri5_FISH","CY_Tri5_GBand","CY_Deletion","CY_Chrom01","CY_Chrom02","CY_Metaphase01","CY_Metaphase02","CY_CompKary","CY_CompKaryB","CY_Diag_FISH","CY_Diag_Conv","STY1","STY2","STY2a","STY3a","STY3b","STY3c","STY3d","STY3e","STY3f","STY3f1","STY3g","STY3h","STY3i","STY3k","STY3l","STY3m","STY3n","STY3o","STY3p","STY3q","STY3r","STY3r1","STY3s","STY3s1","STY3t","STY3t1","STY3u","STY3u1","STY3y","STY3y1","STY3z","STY3z1","STY3g1","STY3h1","STY3i1","STY3k1","STY3l1","STY3m1","STY3n1","STY3o1","STY3p1","STY3q1","STY4a","STY4b","FSH_PercPos","FSH_UCBResults","FSH_UCBProbes","FSH_UCBPercPos","FSH_HospResults","FSH_HospComments","FSH_ConvKaryoDone","FSH_HospFishDone","FSH_UCBFishDone","FAB1","FAB1A","FAB2","FAB3","FAB4","FAB4A","Fab5","FAB_B_Lineage","FAB_T_Lineage","FABClass","DischargeDiag","ICDOCodeID_1990","ICDOCodeID_2000","NumResultsAvailable","FC1A","FC1B","FC1C1","FC1C1b","FC1C1_backup","FC1C2","FC1C2b","FC1C2_backup","FC1C3","FC1C3b","FC1C4","FC1C4b","FC1C5","FC1C5b","FC1C6","FC1C6b","FC1C7","FC1C7b","FC1C8","FC1C8b","FC1C9","FC1C9b","FC1C10","FC1C10b","FC1C11","FC1C11b","FC1C12","FC1C12b","FC1C13","FC1C13b","FC1D1","FC1D1b","FC1D2","FC1D2b","FC1D3","FC1D3b","FC1D4","FC1D4b","FC1D5","FC1D5b","FC1D6","FC1D6b","FC1D7","FC1D7b","FC1D8","FC1D8b","FC1D9","FC1D9b","FC1E1","FC1E1b","FC1E2","FC1E2b","FC1E3","FC1E3b","FC1E4","FC1E4b","FC1E5","FC1E5b","FC1E8","FC1E8b","FC1E9","FC1E9b","FC1F","FC1Fb","FC1G","FC1Gb","FC1H","FC1Hb","FC1I","FC1Ib","FC1J1","FC1J1b","FC1J2","FC1J2b","FC1J3","FC1J3b","FC1K1","FC1K1b","FC1K2","FC1K2b","FC1K3","FC1K3b","FC1K4","FC1K4b","FC1K5","FC1K5b","FC1L1","FC1L1b","FC1L2","FC1L2b","FC1L3a","FC1L3b","FC1L3c","FC1L4a","FC1L4b","FC1L4c","FC1L5a","FC1L5b","FC1L5c","FC1L6a","FC1L6b","FC1L6c","FC1L7a","FC1L7b","FC1L7c","FC1M","FC1L8a","FC1L8b","FC1L8c","FC1L9a","FC1l9b","FC1l9c","FC1l10a","fc1l10b","fc1l10c","FC1l11a","FC1l11b","FC1l11c","FC1l12a","FC1l12b","FC1l12c","FC1l13a","FC1l13b","FC1l13c","FC1l14a","FC1l14b","FC1l14c","HS1","HS2","HS3","ICDO1","ICDO","ID1","ID2","ID3","ID4","ID5","ID6","ID7","ID8","ND4A","ND4B","ND5A","ND5B","ND6A","ND6B","ND6C","ND7","Verified","ND4AID","ND5AID","ND6AID","PE1","PE2","PE3","PE4","PE5","PE5A","PE6","PE6A","PE7","PE7A","PE8","PE9","PE10","PE10A","PE11","PE11A","PE12","PE12A","PE13","PE13b","PE14","PEHepa","PESpleno","DischargeSummaryFound","DischargeSummaryDate","PL1","PL2","PL3","PL4","PL5","PL6","PL7","PL8","PL9","Subtype","BM1A_7","BM1B_7","BM1C_7","BM1D_7_int","BM1D_7","BM1Da_7","FC1A_7","FC1B_7","CD10_7","CD19_7","CD20_7","CD21_7","CD22_7","CD23_7","CD24_7","CD40_7","SurfImmunog_7","CytoIgM_7","BoneMarKappa_7","BoneMarLambda_7","CD19CD10_7","CD1a_7","CD2_7","CD3_7","CD4_7","CD5_7","CD7_7","CD8_7","CD3CD4_7","CD3CD8_7","CD11b_7","CD11c_7","CD13_7","CD15_7","CD33_7","CD41_7","CDw65_7","CD34_7","CD61_7","CD14_7","GlycA_7","CD16_7","CD56_7","CD57_7","CD9_7","CD25_7","CD38_7","CD45_7","CD71_7","TermDoxy_7","HLA-DR_7","Specify1_7","Specify2_7","Specify3_7","Specify4_7","Specify5_7","Other1_7","Other2_7","Other3_7","Other4_7","Other5_7","FCComments","14or28Flag","ChildInRemission","BM1A_14","BM1B_14","BM1C_14","BM1D_14_int","BM1D_14","BM1Da_14","BM1E_14","FC1A_14","FC1B_14","CD10_14","CD19_14","CD20_14","CD21_14","CD22_14","CD23_14","CD24_14","CD40_14","SurfImmunog_14","CytoIgM_14","BoneMarKappa_14","BoneMarLambda_14","CD19CD10_14","CD1a_14","CD2_14","CD3_14","CD4_14","CD5_14","CD7_14","CD8_14","CD3CD4_14","CD3CD8_14","CD11b_14","CD11c_14","CD13_14","CD15_14","CD33_14","CD41_14","CDw65_14","CD34_14","CD61_14","CD14_14","GlycA_14","CD16_14","CD56_14","CD57_14","CD9_14","CD25_14","CD38_14","CD45_14","CD71_14","TermDoxy_14","HLA-DR_14","Specify1_14","Specify2_14","Specify3_14","Specify4_14","Specify5_14","Other1_14","Other2_14","Other3_14","Other4_14","Other5_14","FCComments_14","BM1A_28","BM1B_28","BM1C_28","BM1D_28_int","BM1D_28","BM1Da_28","Remarks","InconclResults_7","InconclResults_14","InconclResults_21","FC2A","FC2B","FC2C","FC2D","FC2E","FC2F","FC2G","Att1","ATT2","ATT3","ATT4","ATT5","ATT6","ATT7","ATT8","ATT9","ATT10","ATT11","ATT12","ATT13","ATT14","ATT15","ATT16","Diagnosis"

			if line['ChildID'].blank?
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: ChildID blank."
				error_file.puts line
				error_file.puts
				next
			end
			study_subject = StudySubject.where(:childid => line['ChildID']).first
			unless study_subject
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: ChildID #{line['ChildID']} not found."
				error_file.puts line
				error_file.puts
				next
			end

			#
			#	Only study_subject_id protected so block creation not needed.
			#
			abstract = study_subject.abstracts.new
			column_names.each do |name|
				if translation_table[name.upcase]
					abstract[translation_table[name.upcase]] = line[name]
				end
			end
			abstract.save

			if abstract.new_record?
				error_file.puts 
				error_file.puts "Line #:#{f.lineno}: #{abstract.errors.full_messages.to_sentence}"
#				error_file.puts "Line #:#{f.lineno}: #{abstract.errors.inspect}"
				error_file.puts line
				error_file.puts
			else
				abstract.reload
				assert abstract.study_subject_id == study_subject.id, 
					"Study Subject mismatch"
##
##	All this will be tough without fixed fields
##
#				column_names.each do |name|
#					if translation_table[name.upcase]
#						assert_string_equal abstract[translation_table[name.upcase]], line[name], name
#					end
#				end

#				assert phone_number.phone_type_id == line["phone_type_id"].to_nil_or_i,
#					"phone_type_id mismatch:#{phone_number.phone_type_id}:" <<
#						"#{line["phone_type_id"]}:"
#				assert phone_number.data_source_id == line["data_source_id"].to_nil_or_i,
#					"data_source_id mismatch:#{phone_number.data_source_id}:" <<
#						"#{line["data_source_id"]}:"
#				#	import will change format of phone number (adds () and - )
#				assert phone_number.phone_number.only_numeric == line["phone_number"].only_numeric,
#					"phone_number mismatch:#{phone_number.phone_number}:" <<
#						"#{line["phone_number"]}:"
#				assert phone_number.current_phone == line["current_phone"].to_nil_or_i,
#					"current_phone mismatch:#{phone_number.current_phone}:" <<
#						"#{line["current_phone"]}:"
#				assert phone_number.is_primary       == line["is_primary"].to_nil_or_boolean, 
#					"is_primary mismatch:#{phone_number.is_primary}:" <<
#						"#{line["is_primary"]}:"
			end

		end	#	).each do |line|
		error_file.close
	end

end
