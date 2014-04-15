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
		merged_by_uid.present?
	end

	scope :merged,
		->{ where(self.arel_table[:merged_by_uid].not_eq(nil) ) }
	scope :unmerged, ->{ where(:merged_by_uid => nil) }

	delegate :patid, :subjectid, :icf_master_id, :vital_status,
		:dob, :hospital, :diagnosis,
			:to => :study_subject, :allow_nil => true

	include ActiveRecordSunspotter::Sunspotability
	
	#	column defaults ...
	#		:default => false
	#		:type => :string
	#		:facetable => false
	#		:orderable => true

	add_sunspot_column(:id, :default => true, :type => :integer)
	add_sunspot_column(:icf_master_id, :default => true )
	add_sunspot_column(:subjectid, :default => true )
	add_sunspot_column(:patid, :default => true )
	add_sunspot_column( :merged, :default => true,
		:meth => ->(s){ ( s.merged? )? 'Yes' : 'No' },
		:facetable => true )
	add_sunspot_column( :vital_status, :default => true,
		:facetable => true )
	add_sunspot_column( :dob,
		:default => true, :type => :date )
	add_sunspot_column( :hospital,
		:default => true, :facetable => true )
	add_sunspot_column( :diagnosis,
		:default => true, :facetable => true )
	add_sunspot_column( :leukemia_class,
		:default => true, :facetable => true )
	add_sunspot_column( :other_all_leukemia_class,
		:facetable => true )
	add_sunspot_column( :other_aml_leukemia_class,
		:facetable => true )
	add_sunspot_column( :leukemia_lineage,
		:facetable => true )
	add_sunspot_column( :icdo_classification_number,
		:facetable => true )
	add_sunspot_column( :icdo_classification_description,
		:default => true )


	add_sunspot_column( :bmb_report_found,
		:meth => ->(s){ YNDK[s.bmb_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :bmb_test_date, :type => :date )
	add_sunspot_column( :bmb_percentage_blasts_known,
		:meth => ->(s){ YNDK[s.bmb_percentage_blasts_known]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :bmb_percentage_blasts )
	add_sunspot_column( :bma_report_found,
		:meth => ->(s){ YNDK[s.bma_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :bma_test_date, :type => :date )
	add_sunspot_column( :bma_percentage_blasts_known,
		:meth => ->(s){ YNDK[s.bma_percentage_blasts_known]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :bma_percentage_blasts )
	add_sunspot_column( :ccs_report_found,
		:meth => ->(s){ YNDK[s.ccs_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ccs_test_date, :type => :date )
	add_sunspot_column( :ccs_peroxidase )
	add_sunspot_column( :ccs_sudan_black )
	add_sunspot_column( :ccs_periodic_acid_schiff )
	add_sunspot_column( :ccs_chloroacetate_esterase )
	add_sunspot_column( :ccs_non_specific_esterase )
	add_sunspot_column( :ccs_alpha_naphthyl_butyrate_esterase )
	add_sunspot_column( :ccs_toluidine_blue )
	add_sunspot_column( :ccs_bcl_2 )
	add_sunspot_column( :ccs_other )
	add_sunspot_column( :dfc_report_found,
		:meth => ->(s){ YNDK[s.dfc_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :dfc_test_date, :type => :date )
	add_sunspot_column( :dfc_numerical_data_available,
		:meth => ->(s){ YNDK[s.dfc_numerical_data_available]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :marker_bmk )
	add_sunspot_column( :marker_bml )
	add_sunspot_column( :marker_cd10 )
	add_sunspot_column( :marker_cd11b )
	add_sunspot_column( :marker_cd11c )
	add_sunspot_column( :marker_cd13 )
	add_sunspot_column( :marker_cd14 )
	add_sunspot_column( :marker_cd15 )
	add_sunspot_column( :marker_cd16 )
	add_sunspot_column( :marker_cd19 )
	add_sunspot_column( :marker_cd19_cd10 )
	add_sunspot_column( :marker_cd1a )
	add_sunspot_column( :marker_cd2 )
	add_sunspot_column( :marker_cd20 )
	add_sunspot_column( :marker_cd21 )
	add_sunspot_column( :marker_cd22 )
	add_sunspot_column( :marker_cd23 )
	add_sunspot_column( :marker_cd24 )
	add_sunspot_column( :marker_cd25 )
	add_sunspot_column( :marker_cd3 )
	add_sunspot_column( :marker_cd33 )
	add_sunspot_column( :marker_cd34 )
	add_sunspot_column( :marker_cd38 )
	add_sunspot_column( :marker_cd3_cd4 )
	add_sunspot_column( :marker_cd3_cd8 )
	add_sunspot_column( :marker_cd4 )
	add_sunspot_column( :marker_cd40 )
	add_sunspot_column( :marker_cd41 )
	add_sunspot_column( :marker_cd45 )
	add_sunspot_column( :marker_cd5 )
	add_sunspot_column( :marker_cd56 )
	add_sunspot_column( :marker_cd57 )
	add_sunspot_column( :marker_cd61 )
	add_sunspot_column( :marker_cd7 )
	add_sunspot_column( :marker_cd71 )
	add_sunspot_column( :marker_cd8 )
	add_sunspot_column( :marker_cd9 )
	add_sunspot_column( :marker_cdw65 )
	add_sunspot_column( :marker_glycophorin_a )
	add_sunspot_column( :marker_hla_dr )
	add_sunspot_column( :marker_igm )
	add_sunspot_column( :marker_sig )
	add_sunspot_column( :marker_tdt )
	add_sunspot_column( :tdt_report_found,
		:meth => ->(s){ YNDK[s.tdt_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :tdt_test_date, :type => :date )
	add_sunspot_column( :tdt_found_where )
	add_sunspot_column( :tdt_result )
	add_sunspot_column( :tdt_numerical_result )
	add_sunspot_column( :ploidy_report_found,
		:meth => ->(s){ YNDK[s.ploidy_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ploidy_test_date, :type => :date )
	add_sunspot_column( :ploidy_found_where )
	add_sunspot_column( :ploidy_hypodiploid )
	add_sunspot_column( :ploidy_pseudodiploid )
	add_sunspot_column( :ploidy_hyperdiploid )
	add_sunspot_column( :ploidy_diploid )
	add_sunspot_column( :ploidy_dna_index )
	add_sunspot_column( :hla_report_found,
		:meth => ->(s){ YNDK[s.hla_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :hla_test_date, :type => :date )
	add_sunspot_column( :cgs_report_found,
		:meth => ->(s){ YNDK[s.cgs_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_test_date, :type => :date )
	add_sunspot_column( :cgs_normal,
		:meth => ->(s){ YNDK[s.cgs_normal]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_conventional_karyotype_done,
		:meth => ->(s){ YNDK[s.cgs_conventional_karyotype_done]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_hospital_fish_done,
		:meth => ->(s){ YNDK[s.cgs_hospital_fish_done]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_hyperdiploidy_detected,
		:meth => ->(s){ YNDK[s.cgs_hyperdiploidy_detected]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_hyperdiploidy_by )
	add_sunspot_column( :cgs_hyperdiploidy_number_of_chromosomes )
	add_sunspot_column( :cgs_t12_21,
		:meth => ->(s){ YNDK[s.cgs_t12_21]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_inv16,
		:meth => ->(s){ YNDK[s.cgs_inv16]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_t1_19,
		:meth => ->(s){ YNDK[s.cgs_t1_19]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_t8_21,
		:meth => ->(s){ YNDK[s.cgs_t8_21]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_t9_22,
		:meth => ->(s){ YNDK[s.cgs_t9_22]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_t15_17,
		:meth => ->(s){ YNDK[s.cgs_t15_17]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_trisomy_4,
		:meth => ->(s){ YNDK[s.cgs_trisomy_4]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_trisomy_5,
		:meth => ->(s){ YNDK[s.cgs_trisomy_5]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_trisomy_10,
		:meth => ->(s){ YNDK[s.cgs_trisomy_10]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_trisomy_17,
		:meth => ->(s){ YNDK[s.cgs_trisomy_17]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_trisomy_21,
		:meth => ->(s){ YNDK[s.cgs_trisomy_21]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_t4_11_q21_q23,
		:meth => ->(s){ YNDK[s.cgs_t4_11_q21_q23]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_deletion_6q,
		:meth => ->(s){ YNDK[s.cgs_deletion_6q]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_deletion_9p,
		:meth => ->(s){ YNDK[s.cgs_deletion_9p]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_t16_16_p13_q22,
		:meth => ->(s){ YNDK[s.cgs_t16_16_p13_q22]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_trisomy_8,
		:meth => ->(s){ YNDK[s.cgs_trisomy_8]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_trisomy_x,
		:meth => ->(s){ YNDK[s.cgs_trisomy_x]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_trisomy_6,
		:meth => ->(s){ YNDK[s.cgs_trisomy_6]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_trisomy_14,
		:meth => ->(s){ YNDK[s.cgs_trisomy_14]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_trisomy_18,
		:meth => ->(s){ YNDK[s.cgs_trisomy_18]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_monosomy_7,
		:meth => ->(s){ YNDK[s.cgs_monosomy_7]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cgs_deletion_16_q22,
		:meth => ->(s){ YNDK[s.cgs_deletion_16_q22]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :omg_abnormalities_found,
		:meth => ->(s){ YNDK[s.omg_abnormalities_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :omg_test_date, :type => :date )
	add_sunspot_column( :omg_p16 )
	add_sunspot_column( :omg_p15 )
	add_sunspot_column( :omg_p53 )
	add_sunspot_column( :omg_ras )
	add_sunspot_column( :omg_all1 )
	add_sunspot_column( :omg_wt1 )
	add_sunspot_column( :omg_bcr )
	add_sunspot_column( :omg_etv6 )
	add_sunspot_column( :omg_fish )
	add_sunspot_column( :em_report_found,
		:meth => ->(s){ YNDK[s.em_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :em_test_date, :type => :date )
	add_sunspot_column( :cbc_report_found,
		:meth => ->(s){ YNDK[s.cbc_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cbc_test_date, :type => :date )
	add_sunspot_column( :cbc_hemoglobin )
	add_sunspot_column( :cbc_leukocyte_count )
	add_sunspot_column( :cbc_number_of_blasts )
	add_sunspot_column( :cbc_percentage_blasts )
	add_sunspot_column( :cbc_platelet_count )
	add_sunspot_column( :csf_report_found,
		:meth => ->(s){ YNDK[s.csf_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :csf_test_date, :type => :date )
	add_sunspot_column( :csf_blasts_present,
		:meth => ->(s){ YNDK[s.csf_blasts_present]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :csf_number_of_blasts )
	add_sunspot_column( :csf_pb_contamination,
		:meth => ->(s){ YNDK[s.csf_pb_contamination]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :csf_rbc )
	add_sunspot_column( :csf_wbc )
	add_sunspot_column( :ob_skin_report_found,
		:meth => ->(s){ YNDK[s.ob_skin_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ob_skin_date, :type => :date )
	add_sunspot_column( :ob_skin_leukemic_cells_present,
		:meth => ->(s){ YNDK[s.ob_skin_leukemic_cells_present]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ob_lymph_node_report_found,
		:meth => ->(s){ YNDK[s.ob_lymph_node_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ob_lymph_node_date, :type => :date )
	add_sunspot_column( :ob_lymph_node_leukemic_cells_present,
		:meth => ->(s){ YNDK[s.ob_lymph_node_leukemic_cells_present]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ob_liver_report_found,
		:meth => ->(s){ YNDK[s.ob_liver_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ob_liver_date, :type => :date )
	add_sunspot_column( :ob_liver_leukemic_cells_present,
		:meth => ->(s){ YNDK[s.ob_liver_leukemic_cells_present]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ob_other_report_found,
		:meth => ->(s){ YNDK[s.ob_other_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ob_other_date, :type => :date )
	add_sunspot_column( :ob_other_site_organ )
	add_sunspot_column( :ob_other_leukemic_cells_present,
		:meth => ->(s){ YNDK[s.ob_other_leukemic_cells_present]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cxr_report_found,
		:meth => ->(s){ YNDK[s.cxr_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cxr_test_date, :type => :date )
	add_sunspot_column( :cxr_result )
	add_sunspot_column( :cct_report_found,
		:meth => ->(s){ YNDK[s.cct_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cct_test_date, :type => :date )
	add_sunspot_column( :cct_result )
	add_sunspot_column( :as_report_found,
		:meth => ->(s){ YNDK[s.as_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :as_test_date, :type => :date )
	add_sunspot_column( :as_normal,
		:meth => ->(s){ YNDK[s.as_normal]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :as_sphenomegaly,
		:meth => ->(s){ YNDK[s.as_sphenomegaly]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :as_hepatomegaly,
		:meth => ->(s){ YNDK[s.as_hepatomegaly]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :as_lymphadenopathy,
		:meth => ->(s){ YNDK[s.as_lymphadenopathy]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :as_other_abdominal_masses,
		:meth => ->(s){ YNDK[s.as_other_abdominal_masses]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :as_ascities,
		:meth => ->(s){ YNDK[s.as_ascities]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ts_report_found,
		:meth => ->(s){ YNDK[s.ts_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ts_test_date, :type => :date )
	add_sunspot_column( :hpr_report_found,
		:meth => ->(s){ YNDK[s.hpr_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :hpr_test_date, :type => :date )
	add_sunspot_column( :hpr_hepatomegaly,
		:meth => ->(s){ YNDK[s.hpr_hepatomegaly]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :hpr_splenomegaly,
		:meth => ->(s){ YNDK[s.hpr_splenomegaly]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :hpr_down_syndrome_phenotype,
		:meth => ->(s){ YNDK[s.hpr_down_syndrome_phenotype]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :height )
	add_sunspot_column( :height_units )
	add_sunspot_column( :weight )
	add_sunspot_column( :weight_units )
	add_sunspot_column( :ds_report_found,
		:meth => ->(s){ YNDK[s.ds_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :ds_test_date, :type => :date )
	add_sunspot_column( :cp_report_found,
		:meth => ->(s){ YNDK[s.cp_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cp_induction_protocol_used,
		:meth => ->(s){ YNDK[s.cp_induction_protocol_used]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :cp_induction_protocol_name_and_number )
	add_sunspot_column( :bma07_report_found,
		:meth => ->(s){ YNDK[s.bma07_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :bma07_test_date, :type => :date )
	add_sunspot_column( :bma07_classification )
	add_sunspot_column( :bma07_inconclusive_results,
		:meth => ->(s){ s.bma07_inconclusive_results? ? 'Yes' : 'No' },
		:type => :string )
	add_sunspot_column( :bma07_percentage_of_blasts )
	add_sunspot_column( :bma14_report_found,
		:meth => ->(s){ YNDK[s.bma14_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :bma14_test_date, :type => :date )
	add_sunspot_column( :bma14_classification )
	add_sunspot_column( :bma14_inconclusive_results,
		:meth => ->(s){ s.bma14_inconclusive_results? ? 'Yes' : 'No' },
		:type => :string )
	add_sunspot_column( :bma14_percentage_of_blasts )
	add_sunspot_column( :bma28_report_found,
		:meth => ->(s){ YNDK[s.bma28_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :bma28_test_date, :type => :date )
	add_sunspot_column( :bma28_classification )
	add_sunspot_column( :bma28_inconclusive_results,
		:meth => ->(s){ s.bma28_inconclusive_results? ? 'Yes' : 'No' },
		:type => :string )
	add_sunspot_column( :bma28_percentage_of_blasts )
	add_sunspot_column( :clinical_remission,
		:meth => ->(s){ YNDK[s.clinical_remission]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :pe_report_found,
		:meth => ->(s){ YNDK[s.pe_report_found]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :pe_test_date, :type => :date )
	add_sunspot_column( :pe_gingival_infiltrates,
		:meth => ->(s){ YNDK[s.pe_gingival_infiltrates]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :pe_leukemic_skin_infiltrates,
		:meth => ->(s){ YNDK[s.pe_leukemic_skin_infiltrates]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :pe_lymphadenopathy,
		:meth => ->(s){ YNDK[s.pe_lymphadenopathy]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :pe_splenomegaly,
		:meth => ->(s){ YNDK[s.pe_splenomegaly]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :pe_splenomegaly_size )
	add_sunspot_column( :pe_hepatomegaly,
		:meth => ->(s){ YNDK[s.pe_hepatomegaly]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :pe_hepatomegaly_size )
	add_sunspot_column( :pe_testicular_mass,
		:meth => ->(s){ YNDK[s.pe_testicular_mass]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :pe_other_soft_tissue,
		:meth => ->(s){ YNDK[s.pe_other_soft_tissue]||'NULL' },
		:facetable => true, :type => :string )
	add_sunspot_column( :pe_other_soft_tissue_location )
	add_sunspot_column( :pe_other_soft_tissue_size )

	searchable_plus

protected

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
		if study_subject and merged_by_uid.present?
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
