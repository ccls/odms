#	Abstracts controller to be used only as nested from StudySubject
class StudySubject::AbstractsController < StudySubjectController

	before_filter :append_current_user_to_params, :only => [:create,:merge]

	before_filter :may_create_abstracts_required,
		:only => [:new,:create,:compare,:merge]
	before_filter :may_read_abstracts_required,
		:only => [:show,:index]
	before_filter :may_update_abstracts_required,
		:only => [:edit,:update]
	before_filter :may_destroy_abstracts_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	before_filter :case_study_subject_required,
		:only => [:new,:create,:compare,:merge]

	before_filter :two_abstracts_required, 
		:only => [:compare,:merge]

	before_filter :compare_abstracts,
		:only => [:compare,:merge]

	def index
		if !@study_subject.is_case?
			render :action => 'not_case' 
		else
			#	in production, @study_subject.abstracts is active relation, which is_empty? true
			@abstracts = @study_subject.abstracts
		end
	end

	def new
		@abstract = @study_subject.abstracts.new(params[:abstract])
	end

	def create
		@abstract = @study_subject.abstracts.new(abstract_params)
		@abstract.save!
		flash[:notice] = 'Success!'
		redirect_to study_subject_abstract_path(@study_subject,@abstract)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the abstract"
		render :action => 'new'
		#	flash, not flash.now since redirecting and not rendering
	end

#	def edit
#	end

	def update
		@abstract.update_attributes!(abstract_params)
		flash[:notice] = 'Success!'
		redirect_to study_subject_abstract_path(@study_subject,@abstract)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the abstract"
		render :action => "edit"
	end

#	def show
#	end

	def destroy
		@abstract.destroy
		redirect_to study_subject_abstracts_path(@study_subject)
	end

	def compare
	end

	def merge
		@abstract = @study_subject.abstracts.new(
			abstract_params.merge(:merging => true).permit! )
		@abstract.save!
		flash[:notice] = 'Success!'
		redirect_to study_subject_abstract_path(@study_subject,@abstract)
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem merging the abstract"
		render :action => "compare"
	end

protected

	def compare_abstracts
		@abstracts = @study_subject.abstracts
		@diffs = @study_subject.abstract_diffs
	end

	def two_abstracts_required
#		abstracts_count = @study_subject.abstracts_count
#	user counter_cache or actually count?
		abstracts_count = @study_subject.abstracts.count
		unless( abstracts_count == 2 )
			access_denied("Must complete 2 abstracts before merging. " <<
				":#{abstracts_count}:")
		end
	end

	def append_current_user_to_params
		params[:abstract] = {} unless params[:abstract]
		#params[:abstract].merge!(:current_user_uid => current_user.uid)
		#	what's the diff?
		params[:abstract][:current_user_uid] = current_user.uid
	end

	def valid_id_required
		if( !params[:id].blank? && @study_subject.abstracts.exists?(params[:id]) )
			@abstract = @study_subject.abstracts.find(params[:id])
		else
			access_denied("Valid id required!", study_subject_abstracts_path(@study_subject))
		end
	end

	def case_study_subject_required
		unless( @study_subject.is_case? )
			access_denied("StudySubject must be Case to have abstract data!",
				@study_subject)
		end
	end

	def abstract_params
		params.require(:abstract).permit(
			:current_user_uid, :bmb_report_found, :bmb_test_date, :bmb_percentage_blasts_known, 
			:bmb_percentage_blasts, :bmb_comments, :bma_report_found, :bma_test_date, 
			:bma_percentage_blasts_known, :bma_percentage_blasts, :bma_comments, 
			:ccs_report_found, :ccs_test_date, :ccs_peroxidase, :ccs_sudan_black, 
			:ccs_periodic_acid_schiff, :ccs_chloroacetate_esterase, 
			:ccs_non_specific_esterase, :ccs_alpha_naphthyl_butyrate_esterase, 
			:ccs_toluidine_blue, :ccs_bcl_2, :ccs_other, :dfc_report_found, 
			:dfc_test_date, :dfc_numerical_data_available, :marker_bmk, :marker_bml, 
			:marker_cd10, :marker_cd11b, :marker_cd11c, :marker_cd13, :marker_cd14, 
			:marker_cd15, :marker_cd16, :marker_cd19, :marker_cd19_cd10, :marker_cd1a, 
			:marker_cd2, :marker_cd20, :marker_cd21, :marker_cd22, :marker_cd23, 
			:marker_cd24, :marker_cd25, :marker_cd3, :marker_cd33, :marker_cd34, 
			:marker_cd38, :marker_cd3_cd4, :marker_cd3_cd8, :marker_cd4, :marker_cd40, 
			:marker_cd41, :marker_cd45, :marker_cd5, :marker_cd56, :marker_cd57, 
			:marker_cd61, :marker_cd7, :marker_cd71, :marker_cd8, :marker_cd9, 
			:marker_cdw65, :marker_glycophorin_a, :marker_hla_dr, :marker_igm, 
			:marker_sig, :marker_tdt, :other_markers, :marker_comments, 
			:tdt_report_found, :tdt_test_date, :tdt_found_where, :tdt_result, 
			:tdt_numerical_result, :ploidy_report_found, :ploidy_test_date, 
			:ploidy_found_where, :ploidy_hypodiploid, :ploidy_pseudodiploid, 
			:ploidy_hyperdiploid, :ploidy_diploid, :ploidy_dna_index, 
			:ploidy_other_dna_measurement, :ploidy_notes, :hla_report_found, 
			:hla_test_date, :hla_results, :cgs_report_found, :cgs_test_date, 
			:cgs_normal, :cgs_conventional_karyotype_done, :cgs_hospital_fish_done, 
			:cgs_hyperdiploidy_detected, :cgs_hyperdiploidy_by, 
			:cgs_hyperdiploidy_number_of_chromosomes, :cgs_t12_21, :cgs_inv16, 
			:cgs_t1_19, :cgs_t8_21, :cgs_t9_22, :cgs_t15_17, :cgs_trisomy_4, 
			:cgs_trisomy_5, :cgs_trisomy_10, :cgs_trisomy_17, :cgs_trisomy_21, 
			:cgs_t4_11_q21_q23, :cgs_deletion_6q, :cgs_deletion_9p, :cgs_t16_16_p13_q22, 
			:cgs_trisomy_8, :cgs_trisomy_x, :cgs_trisomy_6, :cgs_trisomy_14, 
			:cgs_trisomy_18, :cgs_monosomy_7, :cgs_deletion_16_q22, :cgs_others, 
			:cgs_conventional_karyotyping_results, :cgs_hospital_fish_results, 
			:cgs_comments, :omg_abnormalities_found, :omg_test_date, :omg_p16, 
			:omg_p15, :omg_p53, :omg_ras, :omg_all1, :omg_wt1, :omg_bcr, :omg_etv6, 
			:omg_fish, :em_report_found, :em_test_date, :em_comments, :cbc_report_found, 
			:cbc_test_date, :cbc_hemoglobin, :cbc_leukocyte_count, :cbc_number_of_blasts, 
			:cbc_percentage_blasts, :cbc_platelet_count, :csf_report_found, 
			:csf_test_date, :csf_blasts_present, :csf_cytology, :csf_number_of_blasts, 
			:csf_pb_contamination, :csf_rbc, :csf_wbc, :ob_skin_report_found, 
			:ob_skin_date, :ob_skin_leukemic_cells_present, :ob_lymph_node_report_found, 
			:ob_lymph_node_date, :ob_lymph_node_leukemic_cells_present, 
			:ob_liver_report_found, :ob_liver_date, :ob_liver_leukemic_cells_present, 
			:ob_other_report_found, :ob_other_date, :ob_other_site_organ, 
			:ob_other_leukemic_cells_present, :cxr_report_found, :cxr_test_date, 
			:cxr_result, :cxr_mediastinal_mass_description, :cct_report_found, 
			:cct_test_date, :cct_result, :cct_mediastinal_mass_description, 
			:as_report_found, :as_test_date, :as_normal, :as_sphenomegaly, 
			:as_hepatomegaly, :as_lymphadenopathy, :as_other_abdominal_masses, 
			:as_ascities, :as_other_abnormal_findings, :ts_report_found, 
			:ts_test_date, :ts_findings, :hpr_report_found, :hpr_test_date, 
			:hpr_hepatomegaly, :hpr_splenomegaly, :hpr_down_syndrome_phenotype, 
			:height, :height_units, :weight, :weight_units, :ds_report_found, 
			:ds_test_date, :ds_clinical_diagnosis, :cp_report_found, 
			:cp_induction_protocol_used, :cp_induction_protocol_name_and_number, 
			:cp_therapeutic_agents, :bma07_report_found, :bma07_test_date, 
			:bma07_classification, :bma07_inconclusive_results, 
			:bma07_percentage_of_blasts, :bma14_report_found, :bma14_test_date, 
			:bma14_classification, :bma14_inconclusive_results, 
			:bma14_percentage_of_blasts, :bma28_report_found, :bma28_test_date, 
			:bma28_classification, :bma28_inconclusive_results, 
			:bma28_percentage_of_blasts, :clinical_remission, :leukemia_class, 
			:other_all_leukemia_class, :other_aml_leukemia_class, 
			:icdo_classification_number, :icdo_classification_description, 
			:leukemia_lineage, :pe_report_found, :pe_test_date, 
			:pe_gingival_infiltrates, :pe_leukemic_skin_infiltrates, 
			:pe_lymphadenopathy, :pe_lymphadenopathy_description, :pe_splenomegaly, 
			:pe_splenomegaly_size, :pe_hepatomegaly, :pe_hepatomegaly_size, 
			:pe_testicular_mass, :pe_other_soft_tissue, :pe_other_soft_tissue_location, 
			:pe_other_soft_tissue_size, :pe_neurological_abnormalities, 
			:pe_other_abnormal_findings, :abstracted_by, :abstracted_on, 
			:reviewed_by, :reviewed_on)
	end

end
