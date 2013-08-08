#	Abstract model
class Abstract  < ActiveRecord::Base

	belongs_to :study_subject, :counter_cache => true

	with_options :class_name => 'User', :primary_key => 'uid' do |u|
		u.belongs_to :entry_1_by, :foreign_key => 'entry_1_by_uid'
		u.belongs_to :entry_2_by, :foreign_key => 'entry_2_by_uid'
		u.belongs_to :merged_by,  :foreign_key => 'merged_by_uid'
	end

	validations_from_yaml_file

	attr_protected :study_subject_id, :study_subject
	attr_protected :entry_1_by_uid
	attr_protected :entry_2_by_uid
	attr_protected :merged_by_uid

	attr_accessor :current_user
	attr_accessor :merging	#	flag to be used to skip 2 abstract limitation

	validate :subject_has_less_than_three_abstracts, :on => :create
	validate :subject_has_no_merged_abstract, :on => :create

	before_create :set_user
	after_create  :delete_unmerged

#	before_save   :convert_height_to_cm
#	before_save   :convert_weight_to_kg

	#	db_fields may be a bit of a misnomer
	#	perhaps data_fields? 
	def self.db_fields
		column_names - %w(id entry_1_by_uid entry_2_by_uid merged_by_uid study_subject_id
			created_at updated_at)
	end

	def db_fields
		Abstract.db_fields
	end

	def comparable_attributes
		HWIA[attributes.select {|k,v| db_fields.include?(k)}]
	end

	def is_the_same_as?(another_abstract)
		self.diff(another_abstract).blank?
	end

	def diff(another_abstract)
		a1 = self.comparable_attributes
		a2 = Abstract.find(another_abstract).comparable_attributes
		HWIA[a1.select{|k,v| a2[k] != v unless( a2[k].blank? && v.blank? ) }]
	end

	def merged?
		!merged_by_uid.blank?
	end

	scope :merged,   
		->{ where(self.arel_table[:merged_by_uid].not_eq(nil) ) }
	scope :unmerged, ->{ where(:merged_by_uid => nil) }



	include Sunspotability
	
	self.all_sunspot_columns = [ 
		SunspotColumn.new(:id, :default => true, :type => :integer),
		SunspotColumn.new( :bmb_report_found, 
			:meth => ->(s){ YNDK[s.bmb_report_found]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :bmb_test_date, :type => :date ),
		SunspotColumn.new( :bmb_percentage_blasts_known, 
			:meth => ->(s){ YNDK[s.bmb_percentage_blasts_known]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :bmb_percentage_blasts ),
		SunspotColumn.new( :bma_report_found, 
			:meth => ->(s){ YNDK[s.bma_report_found]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :bma_test_date, :type => :date ),
		SunspotColumn.new( :bma_percentage_blasts_known, 
			:meth => ->(s){ YNDK[s.bma_percentage_blasts_known]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :bma_percentage_blasts ),
		SunspotColumn.new( :ccs_report_found, 
			:meth => ->(s){ YNDK[s.ccs_report_found]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :ccs_test_date, :type => :date ),
    SunspotColumn.new( :ccs_peroxidase ),
    SunspotColumn.new( :ccs_sudan_black ),
    SunspotColumn.new( :ccs_periodic_acid_schiff ),
    SunspotColumn.new( :ccs_chloroacetate_esterase ),
    SunspotColumn.new( :ccs_non_specific_esterase ),
    SunspotColumn.new( :ccs_alpha_naphthyl_butyrate_esterase ),
    SunspotColumn.new( :ccs_toluidine_blue ),
    SunspotColumn.new( :ccs_bcl_2 ),
    SunspotColumn.new( :ccs_other ),
		SunspotColumn.new( :dfc_report_found, 
			:meth => ->(s){ YNDK[s.dfc_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :dfc_test_date, :type => :date ),
		SunspotColumn.new( :dfc_numerical_data_available, 
			:meth => ->(s){ YNDK[s.dfc_numerical_data_available]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :marker_bmk ),
    SunspotColumn.new( :marker_bml ),
    SunspotColumn.new( :marker_cd10 ),
    SunspotColumn.new( :marker_cd11b ),
    SunspotColumn.new( :marker_cd11c ),
    SunspotColumn.new( :marker_cd13 ),
    SunspotColumn.new( :marker_cd14 ),
    SunspotColumn.new( :marker_cd15 ),
    SunspotColumn.new( :marker_cd16 ),
    SunspotColumn.new( :marker_cd19 ),
    SunspotColumn.new( :marker_cd19_cd10 ),
    SunspotColumn.new( :marker_cd1a ),
    SunspotColumn.new( :marker_cd2 ),
    SunspotColumn.new( :marker_cd20 ),
    SunspotColumn.new( :marker_cd21 ),
    SunspotColumn.new( :marker_cd22 ),
    SunspotColumn.new( :marker_cd23 ),
    SunspotColumn.new( :marker_cd24 ),
    SunspotColumn.new( :marker_cd25 ),
    SunspotColumn.new( :marker_cd3 ),
    SunspotColumn.new( :marker_cd33 ),
    SunspotColumn.new( :marker_cd34 ),
    SunspotColumn.new( :marker_cd38 ),
    SunspotColumn.new( :marker_cd3_cd4 ),
    SunspotColumn.new( :marker_cd3_cd8 ),
    SunspotColumn.new( :marker_cd4 ),
    SunspotColumn.new( :marker_cd40 ),
    SunspotColumn.new( :marker_cd41 ),
    SunspotColumn.new( :marker_cd45 ),
    SunspotColumn.new( :marker_cd5 ),
    SunspotColumn.new( :marker_cd56 ),
    SunspotColumn.new( :marker_cd57 ),
    SunspotColumn.new( :marker_cd61 ),
    SunspotColumn.new( :marker_cd7 ),
    SunspotColumn.new( :marker_cd71 ),
    SunspotColumn.new( :marker_cd8 ),
    SunspotColumn.new( :marker_cd9 ),
    SunspotColumn.new( :marker_cdw65 ),
    SunspotColumn.new( :marker_glycophorin_a ),
    SunspotColumn.new( :marker_hla_dr ),
    SunspotColumn.new( :marker_igm ),
    SunspotColumn.new( :marker_sig ),
    SunspotColumn.new( :marker_tdt ),
		SunspotColumn.new( :tdt_report_found, 
			:meth => ->(s){ YNDK[s.tdt_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :tdt_test_date, :type => :date ),
    SunspotColumn.new( :tdt_found_where ),
    SunspotColumn.new( :tdt_result ),
    SunspotColumn.new( :tdt_numerical_result ),
		SunspotColumn.new( :ploidy_report_found, 
			:meth => ->(s){ YNDK[s.ploidy_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :ploidy_test_date, :type => :date ),
    SunspotColumn.new( :ploidy_found_where ),
    SunspotColumn.new( :ploidy_hypodiploid ),
    SunspotColumn.new( :ploidy_pseudodiploid ),
    SunspotColumn.new( :ploidy_hyperdiploid ),
    SunspotColumn.new( :ploidy_diploid ),
    SunspotColumn.new( :ploidy_dna_index ),
		SunspotColumn.new( :hla_report_found, 
			:meth => ->(s){ YNDK[s.hla_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :hla_test_date, :type => :date ),
		SunspotColumn.new( :cgs_report_found, 
			:meth => ->(s){ YNDK[s.cgs_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :cgs_test_date, :type => :date ),
		SunspotColumn.new( :cgs_normal, 
			:meth => ->(s){ YNDK[s.cgs_normal]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_conventional_karyotype_done, 
			:meth => ->(s){ YNDK[s.cgs_conventional_karyotype_done]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_hospital_fish_done, 
			:meth => ->(s){ YNDK[s.cgs_hospital_fish_done]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_hyperdiploidy_detected, 
			:meth => ->(s){ YNDK[s.cgs_hyperdiploidy_detected]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :cgs_hyperdiploidy_by ),
    SunspotColumn.new( :cgs_hyperdiploidy_number_of_chromosomes ),
		SunspotColumn.new( :cgs_t12_21, 
			:meth => ->(s){ YNDK[s.cgs_t12_21]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_inv16, 
			:meth => ->(s){ YNDK[s.cgs_inv16]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_t1_19, 
			:meth => ->(s){ YNDK[s.cgs_t1_19]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_t8_21, 
			:meth => ->(s){ YNDK[s.cgs_t8_21]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_t9_22, 
			:meth => ->(s){ YNDK[s.cgs_t9_22]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_t15_17, 
			:meth => ->(s){ YNDK[s.cgs_t15_17]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_trisomy_4, 
			:meth => ->(s){ YNDK[s.cgs_trisomy_4]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_trisomy_5, 
			:meth => ->(s){ YNDK[s.cgs_trisomy_5]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_trisomy_10, 
			:meth => ->(s){ YNDK[s.cgs_trisomy_10]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_trisomy_17, 
			:meth => ->(s){ YNDK[s.cgs_trisomy_17]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_trisomy_21, 
			:meth => ->(s){ YNDK[s.cgs_trisomy_21]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_t4_11_q21_q23, 
			:meth => ->(s){ YNDK[s.cgs_t4_11_q21_q23]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_deletion_6q, 
			:meth => ->(s){ YNDK[s.cgs_deletion_6q]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_deletion_9p, 
			:meth => ->(s){ YNDK[s.cgs_deletion_9p]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_t16_16_p13_q22, 
			:meth => ->(s){ YNDK[s.cgs_t16_16_p13_q22]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_trisomy_8, 
			:meth => ->(s){ YNDK[s.cgs_trisomy_8]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_trisomy_x, 
			:meth => ->(s){ YNDK[s.cgs_trisomy_x]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_trisomy_6, 
			:meth => ->(s){ YNDK[s.cgs_trisomy_6]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_trisomy_14, 
			:meth => ->(s){ YNDK[s.cgs_trisomy_14]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_trisomy_18, 
			:meth => ->(s){ YNDK[s.cgs_trisomy_18]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_monosomy_7, 
			:meth => ->(s){ YNDK[s.cgs_monosomy_7]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cgs_deletion_16_q22, 
			:meth => ->(s){ YNDK[s.cgs_deletion_16_q22]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :omg_abnormalities_found, 
			:meth => ->(s){ YNDK[s.omg_abnormalities_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :omg_test_date, :type => :date ),
    SunspotColumn.new( :omg_p16 ),
    SunspotColumn.new( :omg_p15 ),
    SunspotColumn.new( :omg_p53 ),
    SunspotColumn.new( :omg_ras ),
    SunspotColumn.new( :omg_all1 ),
    SunspotColumn.new( :omg_wt1 ),
    SunspotColumn.new( :omg_bcr ),
    SunspotColumn.new( :omg_etv6 ),
    SunspotColumn.new( :omg_fish ),
		SunspotColumn.new( :em_report_found, 
			:meth => ->(s){ YNDK[s.em_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :em_test_date, :type => :date ),
		SunspotColumn.new( :cbc_report_found, 
			:meth => ->(s){ YNDK[s.cbc_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :cbc_test_date, :type => :date ),
    SunspotColumn.new( :cbc_hemoglobin ),
    SunspotColumn.new( :cbc_leukocyte_count ),
    SunspotColumn.new( :cbc_number_of_blasts ),
    SunspotColumn.new( :cbc_percentage_blasts ),
    SunspotColumn.new( :cbc_platelet_count ),
		SunspotColumn.new( :csf_report_found, 
			:meth => ->(s){ YNDK[s.csf_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :csf_test_date, :type => :date ),
		SunspotColumn.new( :csf_blasts_present, 
			:meth => ->(s){ YNDK[s.csf_blasts_present]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :csf_number_of_blasts ),
		SunspotColumn.new( :csf_pb_contamination, 
			:meth => ->(s){ YNDK[s.csf_pb_contamination]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :csf_rbc ),
    SunspotColumn.new( :csf_wbc ),
		SunspotColumn.new( :ob_skin_report_found, 
			:meth => ->(s){ YNDK[s.ob_skin_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :ob_skin_date, :type => :date ),
		SunspotColumn.new( :ob_skin_leukemic_cells_present, 
			:meth => ->(s){ YNDK[s.ob_skin_leukemic_cells_present]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :ob_lymph_node_report_found, 
			:meth => ->(s){ YNDK[s.ob_lymph_node_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :ob_lymph_node_date, :type => :date ),
		SunspotColumn.new( :ob_lymph_node_leukemic_cells_present, 
			:meth => ->(s){ YNDK[s.ob_lymph_node_leukemic_cells_present]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :ob_liver_report_found, 
			:meth => ->(s){ YNDK[s.ob_liver_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :ob_liver_date, :type => :date ),
		SunspotColumn.new( :ob_liver_leukemic_cells_present, 
			:meth => ->(s){ YNDK[s.ob_liver_leukemic_cells_present]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :ob_other_report_found, 
			:meth => ->(s){ YNDK[s.ob_other_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :ob_other_date, :type => :date ),
    SunspotColumn.new( :ob_other_site_organ ),
		SunspotColumn.new( :ob_other_leukemic_cells_present, 
			:meth => ->(s){ YNDK[s.ob_other_leukemic_cells_present]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cxr_report_found, 
			:meth => ->(s){ YNDK[s.cxr_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :cxr_test_date, :type => :date ),
    SunspotColumn.new( :cxr_result ),
		SunspotColumn.new( :cct_report_found, 
			:meth => ->(s){ YNDK[s.cct_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :cct_test_date, :type => :date ),
    SunspotColumn.new( :cct_result ),
		SunspotColumn.new( :as_report_found, 
			:meth => ->(s){ YNDK[s.as_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :as_test_date, :type => :date ),
		SunspotColumn.new( :as_normal, 
			:meth => ->(s){ YNDK[s.as_normal]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :as_sphenomegaly, 
			:meth => ->(s){ YNDK[s.as_sphenomegaly]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :as_hepatomegaly, 
			:meth => ->(s){ YNDK[s.as_hepatomegaly]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :as_lymphadenopathy, 
			:meth => ->(s){ YNDK[s.as_lymphadenopathy]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :as_other_abdominal_masses, 
			:meth => ->(s){ YNDK[s.as_other_abdominal_masses]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :as_ascities, 
			:meth => ->(s){ YNDK[s.as_ascities]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :ts_report_found, 
			:meth => ->(s){ YNDK[s.ts_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :ts_test_date, :type => :date ),
		SunspotColumn.new( :hpr_report_found, 
			:meth => ->(s){ YNDK[s.hpr_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :hpr_test_date, :type => :date ),
		SunspotColumn.new( :hpr_hepatomegaly, 
			:meth => ->(s){ YNDK[s.hpr_hepatomegaly]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :hpr_splenomegaly, 
			:meth => ->(s){ YNDK[s.hpr_splenomegaly]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :hpr_down_syndrome_phenotype, 
			:meth => ->(s){ YNDK[s.hpr_down_syndrome_phenotype]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :height ),
    SunspotColumn.new( :height_units ),
    SunspotColumn.new( :weight ),
    SunspotColumn.new( :weight_units ),
		SunspotColumn.new( :ds_report_found, 
			:meth => ->(s){ YNDK[s.ds_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :ds_test_date, :type => :date ),
		SunspotColumn.new( :cp_report_found, 
			:meth => ->(s){ YNDK[s.cp_report_found]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :cp_induction_protocol_used, 
			:meth => ->(s){ YNDK[s.cp_induction_protocol_used]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :cp_induction_protocol_name_and_number ),
		SunspotColumn.new( :bma07_report_found, 
			:meth => ->(s){ YNDK[s.bma07_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :bma07_test_date, :type => :date ),
    SunspotColumn.new( :bma07_classification ),
		SunspotColumn.new( :bma07_inconclusive_results, 
			:meth => ->(s){ s.bma07_inconclusive_results? ? 'Yes' : 'No' },
			:type => :string ),
    SunspotColumn.new( :bma07_percentage_of_blasts ),
		SunspotColumn.new( :bma14_report_found, 
			:meth => ->(s){ YNDK[s.bma14_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :bma14_test_date, :type => :date ),
    SunspotColumn.new( :bma14_classification ),
		SunspotColumn.new( :bma14_inconclusive_results, 
			:meth => ->(s){ s.bma14_inconclusive_results? ? 'Yes' : 'No' },
			:type => :string ),
    SunspotColumn.new( :bma14_percentage_of_blasts ),
		SunspotColumn.new( :bma28_report_found, 
			:meth => ->(s){ YNDK[s.bma28_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :bma28_test_date, :type => :date ),
    SunspotColumn.new( :bma28_classification ),
		SunspotColumn.new( :bma28_inconclusive_results, 
			:meth => ->(s){ s.bma28_inconclusive_results? ? 'Yes' : 'No' },
			:type => :string ),
    SunspotColumn.new( :bma28_percentage_of_blasts ),
		SunspotColumn.new( :clinical_remission, 
			:meth => ->(s){ YNDK[s.clinical_remission]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :leukemia_class ),
    SunspotColumn.new( :other_all_leukemia_class ),
    SunspotColumn.new( :other_aml_leukemia_class ),
    SunspotColumn.new( :icdo_classification_number ),
    SunspotColumn.new( :leukemia_lineage ),
		SunspotColumn.new( :pe_report_found, 
			:meth => ->(s){ YNDK[s.pe_report_found]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :pe_test_date, :type => :date ),
		SunspotColumn.new( :pe_gingival_infiltrates, 
			:meth => ->(s){ YNDK[s.pe_gingival_infiltrates]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :pe_leukemic_skin_infiltrates, 
			:meth => ->(s){ YNDK[s.pe_leukemic_skin_infiltrates]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :pe_lymphadenopathy, 
			:meth => ->(s){ YNDK[s.pe_lymphadenopathy]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :pe_splenomegaly, 
			:meth => ->(s){ YNDK[s.pe_splenomegaly]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :pe_splenomegaly_size ),
		SunspotColumn.new( :pe_hepatomegaly, 
			:meth => ->(s){ YNDK[s.pe_hepatomegaly]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :pe_hepatomegaly_size ),
		SunspotColumn.new( :pe_testicular_mass, 
			:meth => ->(s){ YNDK[s.pe_testicular_mass]||'NULL' },
			:facetable => true, :type => :string ),
		SunspotColumn.new( :pe_other_soft_tissue, 
			:meth => ->(s){ YNDK[s.pe_other_soft_tissue]||'NULL' },
			:facetable => true, :type => :string ),
    SunspotColumn.new( :pe_other_soft_tissue_location ),
    SunspotColumn.new( :pe_other_soft_tissue_size )

#			t.text    :bmb_comments
#			t.text    :bma_comments
#			t.text    :other_markers
#			t.text    :marker_comments
#			t.text    :ploidy_other_dna_measurement
#			t.text    :ploidy_notes
#			t.text    :hla_results
#			t.text    :cgs_others
#			t.text    :cgs_conventional_karyotyping_results
#			t.text    :cgs_hospital_fish_results
#			t.text    :cgs_comments
#			t.text    :em_comments
#			t.text    :csf_cytology
#			t.text    :cxr_mediastinal_mass_description
#			t.text    :cct_mediastinal_mass_description
#			t.text    :as_other_abnormal_findings
#			t.text    :ts_findings
#			t.text    :ds_clinical_diagnosis
#			t.text    :cp_therapeutic_agents
#			t.text    :icdo_classification_description
#			t.text    :pe_lymphadenopathy_description
#			t.text    :pe_neurological_abnormalities
#			t.text    :pe_other_abnormal_findings

	]

	searchable_plus


protected

#	def convert_height_to_cm
#		if( !height_units.nil? && height_units.match(/in/i) )
#			self.height_units = nil
#			self.height_at_diagnosis *= 2.54
#		end
#	end
#
#	def convert_weight_to_kg
#		if( !weight_units.nil? && weight_units.match(/lb/i) )
#			self.weight_units = nil
#			self.weight_at_diagnosis /= 2.2046
#		end
#	end

	#	Set user if given
	def set_user
		if study_subject
			#	because it is possible to create the first, then the second
			#	and then delete the first, and create another, first and
			#	second kinda lose their meaning until the merge, so set them
			#	both as the same until the merge
			case study_subject.abstracts.count
				when 0 
					self.entry_1_by_uid = current_user.try(:uid)||0
					self.entry_2_by_uid = current_user.try(:uid)||0
				when 1 
					self.entry_1_by_uid = current_user.try(:uid)||0
					self.entry_2_by_uid = current_user.try(:uid)||0
				when 2
					abs = study_subject.abstracts
					#	compact just in case a nil crept in
					self.entry_1_by_uid = [abs[0].entry_1_by_uid,abs[0].entry_2_by_uid].compact.first
					self.entry_2_by_uid = [abs[1].entry_1_by_uid,abs[1].entry_2_by_uid].compact.first
					self.merged_by_uid  = current_user.try(:uid)||0
			end
		end
	end

	def delete_unmerged
		if study_subject and !merged_by_uid.blank?
			#	use delete and not destroy to preserve the abstracts_count
#	gonna stop using abstracts_count so really won't matter
#			study_subject.abstracts.unmerged.each{|a|a.delete}
#	actually using it, but since will synch the counters every now and again, won't work
#	was hoping to using the counter as a flag that the subject's abstracts were merged
#	now no way to determine if merged or just the first abstract entered.
			study_subject.abstracts.unmerged.each{|a|a.destroy}
		end
	end

	def subject_has_less_than_three_abstracts
		#	because this abstract hasn't been created yet, we're comparing to 2, not 3
		if study_subject and study_subject.abstracts.count >= 2 and !merging
			errors.add(:study_subject_id,"Study Subject can only have 2 unmerged abstracts.")
		end
	end

	def subject_has_no_merged_abstract
		if study_subject and !study_subject.abstracts.merged.empty?
			errors.add(:study_subject_id,"Study Subject already has a merged abstract." )
		end
	end

end
__END__
