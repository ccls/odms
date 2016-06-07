#	Abstract model
class Abstract  < ActiveRecord::Base

	belongs_to :study_subject, :counter_cache => true

	with_options :class_name => 'User', :primary_key => 'uid' do |u|
		u.belongs_to :entry_1_by, :foreign_key => 'entry_1_by_uid'
		u.belongs_to :entry_2_by, :foreign_key => 'entry_2_by_uid'
		u.belongs_to :merged_by,  :foreign_key => 'merged_by_uid'
	end

	validations_from_yaml_file

	attr_accessor :current_user_uid
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
		a2 = Abstract.find(another_abstract.id).comparable_attributes
		HWIA[a1.select{|k,v| a2[k] != v unless( a2[k].blank? && v.blank? ) }]
	end

	def merged?
		merged_by_uid.present?
	end

	scope :merged,
		->{ where(self.arel_table[:merged_by_uid].not_eq(nil) ) }
	scope :unmerged, ->{ where(:merged_by_uid => nil) }
	scope :mergable, ->{ joins(:study_subject).where(:'study_subjects.abstracts_count' => 2) }

#	almost mergable, but only returns 1 abstract per study_subject
#Abstract.group(:study_subject_id).select('COUNT(`abstracts`.`study_subject_id`) AS count_study_subject_id, `abstracts`.*').having('count_study_subject_id = 2').order(:study_subject_id)

	delegate :patid, :subjectid, :icf_master_id, :vital_status,
		:dob, :hospital, :diagnosis, :phase,
			:to => :study_subject, :allow_nil => true

	include ActiveRecordSunspotter::Sunspotability
	
	#	column defaults ...
	#		:default => false
	#		:type => :string
	#		:facetable => false
	#		:orderable => true

	add_sunspot_column( :id, :default => true, :type => :integer)
	add_sunspot_column( :icf_master_id, :default => true )
	add_sunspot_column( :subjectid, :default => true )
	add_sunspot_column( :patid, :default => true )
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
	add_sunspot_column( :phase, :type => :integer,
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

#		Field name prefixes (use them to group columns and facets? IF ENOUGH IN GROUP!)
#		Hmm.  What if want to group column, but not facet (or vice versa)
#		Not all columns are facetable and would result in small groups.
#	bmb -> Bone Marrow Biopsy
#	bma -> Bone Marrow Aspirate (or smears)
#	ccs -> Cytochemical Stains (or Histochemistry)
#	dfc -> Diagnostic Flow Cytometry (or Immunophenotyping)
#		(cell markers here too)
#	tdt -> Terminal Deoxynucleotydyl Transferase
#	ploidy -> Ploidy (or DNA Content)
#	hla -> Histocompatibility Studies (or HLA-Typing)
#	cgs -> Cytogenetic Studies
#	omg -> Other Molecular / Genetic Abnormalities (or OMG)		(poor choice, lol)
#	em -> Electron Microscopy
#	cbc -> Complete Blood Count
#	csf -> Cerebrospinal Fluid
#	ob -> Other Biopsies
#	cxr -> Chest X-Ray
#	cct -> Chest CT Scan
#	as -> Abdominal Sonogram, CT scan or MRI before treatment
#	ts -> Testicular Sonogram
#	hpr -> History and Physical Report
#	ds -> Discharge Summary
#	cp -> Chemotherapy Protocol
#	pe -> Physical Exam before treatment

	add_sunspot_column( :bmb_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.bmb_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :bmb_test_date, :type => :date )
	add_sunspot_column( :bmb_percentage_blasts_known,
		:meth => ->(s){ YNDK[s.bmb_percentage_blasts_known]||'NULL' },
		:facetable => true )
	add_sunspot_column( :bmb_percentage_blasts )
	add_sunspot_column( :bma_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.bma_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :bma_test_date, :type => :date )
	add_sunspot_column( :bma_percentage_blasts_known,
		:meth => ->(s){ YNDK[s.bma_percentage_blasts_known]||'NULL' },
		:facetable => true )
	add_sunspot_column( :bma_percentage_blasts )
	add_sunspot_column( :ccs_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.ccs_report_found]||'NULL' },
		:facetable => true )
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
	add_sunspot_column( :dfc_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.dfc_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :dfc_test_date, :type => :date )
	add_sunspot_column( :dfc_numerical_data_available,
		:meth => ->(s){ YNDK[s.dfc_numerical_data_available]||'NULL' },
		:facetable => true )

	with_options(:group => "Markers" ) do |o|
		o.add_sunspot_column( :marker_bmk )
		o.add_sunspot_column( :marker_bml )
		o.add_sunspot_column( :marker_cd10 )
		o.add_sunspot_column( :marker_cd11b )
		o.add_sunspot_column( :marker_cd11c )
		o.add_sunspot_column( :marker_cd13 )
		o.add_sunspot_column( :marker_cd14 )
		o.add_sunspot_column( :marker_cd15 )
		o.add_sunspot_column( :marker_cd16 )
		o.add_sunspot_column( :marker_cd19 )
		o.add_sunspot_column( :marker_cd19_cd10 )
		o.add_sunspot_column( :marker_cd1a )
		o.add_sunspot_column( :marker_cd2 )
		o.add_sunspot_column( :marker_cd20 )
		o.add_sunspot_column( :marker_cd21 )
		o.add_sunspot_column( :marker_cd22 )
		o.add_sunspot_column( :marker_cd23 )
		o.add_sunspot_column( :marker_cd24 )
		o.add_sunspot_column( :marker_cd25 )
		o.add_sunspot_column( :marker_cd3 )
		o.add_sunspot_column( :marker_cd33 )
		o.add_sunspot_column( :marker_cd34 )
		o.add_sunspot_column( :marker_cd38 )
		o.add_sunspot_column( :marker_cd3_cd4 )
		o.add_sunspot_column( :marker_cd3_cd8 )
		o.add_sunspot_column( :marker_cd4 )
		o.add_sunspot_column( :marker_cd40 )
		o.add_sunspot_column( :marker_cd41 )
		o.add_sunspot_column( :marker_cd45 )
		o.add_sunspot_column( :marker_cd5 )
		o.add_sunspot_column( :marker_cd56 )
		o.add_sunspot_column( :marker_cd57 )
		o.add_sunspot_column( :marker_cd61 )
		o.add_sunspot_column( :marker_cd7 )
		o.add_sunspot_column( :marker_cd71 )
		o.add_sunspot_column( :marker_cd8 )
		o.add_sunspot_column( :marker_cd9 )
		o.add_sunspot_column( :marker_cdw65 )
		o.add_sunspot_column( :marker_glycophorin_a )
		o.add_sunspot_column( :marker_hla_dr )
		o.add_sunspot_column( :marker_igm )
		o.add_sunspot_column( :marker_sig )
		o.add_sunspot_column( :marker_tdt )
	end

	add_sunspot_column( :tdt_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.tdt_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :tdt_test_date, :type => :date )
	add_sunspot_column( :tdt_found_where )
	add_sunspot_column( :tdt_result )
	add_sunspot_column( :tdt_numerical_result )
	add_sunspot_column( :ploidy_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.ploidy_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :ploidy_test_date, :type => :date )
	add_sunspot_column( :ploidy_found_where )
	add_sunspot_column( :ploidy_hypodiploid )
	add_sunspot_column( :ploidy_pseudodiploid )
	add_sunspot_column( :ploidy_hyperdiploid )
	add_sunspot_column( :ploidy_diploid )
	add_sunspot_column( :ploidy_dna_index )
	add_sunspot_column( :hla_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.hla_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :hla_test_date, :type => :date )
	add_sunspot_column( :cgs_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.cgs_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :cgs_test_date, :type => :date )
	add_sunspot_column( :cgs_normal,
		:meth => ->(s){ YNDK[s.cgs_normal]||'NULL' },
		:facetable => true )
	add_sunspot_column( :cgs_conventional_karyotype_done,
		:meth => ->(s){ YNDK[s.cgs_conventional_karyotype_done]||'NULL' },
		:facetable => true )
	add_sunspot_column( :cgs_hospital_fish_done,
		:meth => ->(s){ YNDK[s.cgs_hospital_fish_done]||'NULL' },
		:facetable => true )
	add_sunspot_column( :cgs_hyperdiploidy_detected,
		:meth => ->(s){ YNDK[s.cgs_hyperdiploidy_detected]||'NULL' },
		:facetable => true )
	add_sunspot_column( :cgs_hyperdiploidy_by )
	add_sunspot_column( :cgs_hyperdiploidy_number_of_chromosomes )

	with_options(:group => "CGS Trisomies" ) do |o|
		o.add_sunspot_column( :cgs_t12_21,
			:meth => ->(s){ YNDK[s.cgs_t12_21]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_inv16,
			:meth => ->(s){ YNDK[s.cgs_inv16]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_t1_19,
			:meth => ->(s){ YNDK[s.cgs_t1_19]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_t8_21,
			:meth => ->(s){ YNDK[s.cgs_t8_21]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_t9_22,
			:meth => ->(s){ YNDK[s.cgs_t9_22]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_t15_17,
			:meth => ->(s){ YNDK[s.cgs_t15_17]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_trisomy_4,
			:meth => ->(s){ YNDK[s.cgs_trisomy_4]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_trisomy_5,
			:meth => ->(s){ YNDK[s.cgs_trisomy_5]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_trisomy_10,
			:meth => ->(s){ YNDK[s.cgs_trisomy_10]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_trisomy_17,
			:meth => ->(s){ YNDK[s.cgs_trisomy_17]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_trisomy_21,
			:meth => ->(s){ YNDK[s.cgs_trisomy_21]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_t4_11_q21_q23,
			:meth => ->(s){ YNDK[s.cgs_t4_11_q21_q23]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_deletion_6q,
			:meth => ->(s){ YNDK[s.cgs_deletion_6q]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_deletion_9p,
			:meth => ->(s){ YNDK[s.cgs_deletion_9p]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_t16_16_p13_q22,
			:meth => ->(s){ YNDK[s.cgs_t16_16_p13_q22]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_trisomy_8,
			:meth => ->(s){ YNDK[s.cgs_trisomy_8]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_trisomy_x,
			:meth => ->(s){ YNDK[s.cgs_trisomy_x]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_trisomy_6,
			:meth => ->(s){ YNDK[s.cgs_trisomy_6]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_trisomy_14,
			:meth => ->(s){ YNDK[s.cgs_trisomy_14]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_trisomy_18,
			:meth => ->(s){ YNDK[s.cgs_trisomy_18]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_monosomy_7,
			:meth => ->(s){ YNDK[s.cgs_monosomy_7]||'NULL' },
			:facetable => true )
		o.add_sunspot_column( :cgs_deletion_16_q22,
			:meth => ->(s){ YNDK[s.cgs_deletion_16_q22]||'NULL' },
			:facetable => true )
	end

	add_sunspot_column( :omg_abnormalities_found,
		:meth => ->(s){ YNDK[s.omg_abnormalities_found]||'NULL' },
		:facetable => true )
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
	add_sunspot_column( :em_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.em_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :em_test_date, :type => :date )
	add_sunspot_column( :cbc_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.cbc_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :cbc_test_date, :type => :date )
	add_sunspot_column( :cbc_hemoglobin )
	add_sunspot_column( :cbc_leukocyte_count )
	add_sunspot_column( :cbc_number_of_blasts )
	add_sunspot_column( :cbc_percentage_blasts )
	add_sunspot_column( :cbc_platelet_count )
	add_sunspot_column( :csf_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.csf_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :csf_test_date, :type => :date )
	add_sunspot_column( :csf_blasts_present,
		:meth => ->(s){ YNDK[s.csf_blasts_present]||'NULL' },
		:facetable => true )
	add_sunspot_column( :csf_number_of_blasts )
	add_sunspot_column( :csf_pb_contamination,
		:meth => ->(s){ YNDK[s.csf_pb_contamination]||'NULL' },
		:facetable => true )
	add_sunspot_column( :csf_rbc )
	add_sunspot_column( :csf_wbc )
	add_sunspot_column( :ob_skin_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.ob_skin_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :ob_skin_date, :type => :date )
	add_sunspot_column( :ob_skin_leukemic_cells_present,
		:meth => ->(s){ YNDK[s.ob_skin_leukemic_cells_present]||'NULL' },
		:facetable => true )
	add_sunspot_column( :ob_lymph_node_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.ob_lymph_node_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :ob_lymph_node_date, :type => :date )
	add_sunspot_column( :ob_lymph_node_leukemic_cells_present,
		:meth => ->(s){ YNDK[s.ob_lymph_node_leukemic_cells_present]||'NULL' },
		:facetable => true )
	add_sunspot_column( :ob_liver_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.ob_liver_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :ob_liver_date, :type => :date )
	add_sunspot_column( :ob_liver_leukemic_cells_present,
		:meth => ->(s){ YNDK[s.ob_liver_leukemic_cells_present]||'NULL' },
		:facetable => true )
	add_sunspot_column( :ob_other_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.ob_other_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :ob_other_date, :type => :date )
	add_sunspot_column( :ob_other_site_organ )
	add_sunspot_column( :ob_other_leukemic_cells_present,
		:meth => ->(s){ YNDK[s.ob_other_leukemic_cells_present]||'NULL' },
		:facetable => true )
	add_sunspot_column( :cxr_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.cxr_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :cxr_test_date, :type => :date )
	add_sunspot_column( :cxr_result )
	add_sunspot_column( :cct_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.cct_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :cct_test_date, :type => :date )
	add_sunspot_column( :cct_result )
	add_sunspot_column( :as_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.as_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :as_test_date, :type => :date )
	add_sunspot_column( :as_normal,
		:meth => ->(s){ YNDK[s.as_normal]||'NULL' },
		:facetable => true )
	add_sunspot_column( :as_sphenomegaly,
		:meth => ->(s){ YNDK[s.as_sphenomegaly]||'NULL' },
		:facetable => true )
	add_sunspot_column( :as_hepatomegaly,
		:meth => ->(s){ YNDK[s.as_hepatomegaly]||'NULL' },
		:facetable => true )
	add_sunspot_column( :as_lymphadenopathy,
		:meth => ->(s){ YNDK[s.as_lymphadenopathy]||'NULL' },
		:facetable => true )
	add_sunspot_column( :as_other_abdominal_masses,
		:meth => ->(s){ YNDK[s.as_other_abdominal_masses]||'NULL' },
		:facetable => true )
	add_sunspot_column( :as_ascities,
		:meth => ->(s){ YNDK[s.as_ascities]||'NULL' },
		:facetable => true )
	add_sunspot_column( :ts_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.ts_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :ts_test_date, :type => :date )
	add_sunspot_column( :hpr_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.hpr_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :hpr_test_date, :type => :date )
	add_sunspot_column( :hpr_hepatomegaly,
		:meth => ->(s){ YNDK[s.hpr_hepatomegaly]||'NULL' },
		:facetable => true )
	add_sunspot_column( :hpr_splenomegaly,
		:meth => ->(s){ YNDK[s.hpr_splenomegaly]||'NULL' },
		:facetable => true )
	add_sunspot_column( :hpr_down_syndrome_phenotype,
		:meth => ->(s){ YNDK[s.hpr_down_syndrome_phenotype]||'NULL' },
		:facetable => true )
	add_sunspot_column( :height )
	add_sunspot_column( :height_units )
	add_sunspot_column( :weight )
	add_sunspot_column( :weight_units )
	add_sunspot_column( :ds_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.ds_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :ds_test_date, :type => :date )
	add_sunspot_column( :cp_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.cp_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :cp_induction_protocol_used,
		:meth => ->(s){ YNDK[s.cp_induction_protocol_used]||'NULL' },
		:facetable => true )
	add_sunspot_column( :cp_induction_protocol_name_and_number )
	add_sunspot_column( :bma07_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.bma07_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :bma07_test_date, :type => :date )
	add_sunspot_column( :bma07_classification )
	add_sunspot_column( :bma07_inconclusive_results,
		:meth => ->(s){ s.bma07_inconclusive_results? ? 'Yes' : 'No' } )
	add_sunspot_column( :bma07_percentage_of_blasts )
	add_sunspot_column( :bma14_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.bma14_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :bma14_test_date, :type => :date )
	add_sunspot_column( :bma14_classification )
	add_sunspot_column( :bma14_inconclusive_results,
		:meth => ->(s){ s.bma14_inconclusive_results? ? 'Yes' : 'No' } )
	add_sunspot_column( :bma14_percentage_of_blasts )
	add_sunspot_column( :bma28_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.bma28_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :bma28_test_date, :type => :date )
	add_sunspot_column( :bma28_classification )
	add_sunspot_column( :bma28_inconclusive_results,
		:meth => ->(s){ s.bma28_inconclusive_results? ? 'Yes' : 'No' })
	add_sunspot_column( :bma28_percentage_of_blasts )
	add_sunspot_column( :clinical_remission,
		:meth => ->(s){ YNDK[s.clinical_remission]||'NULL' },
		:facetable => true )
	add_sunspot_column( :pe_report_found, :group => 'Reports Found',
		:meth => ->(s){ YNDK[s.pe_report_found]||'NULL' },
		:facetable => true )
	add_sunspot_column( :pe_test_date, :type => :date )
	add_sunspot_column( :pe_gingival_infiltrates,
		:meth => ->(s){ YNDK[s.pe_gingival_infiltrates]||'NULL' },
		:facetable => true )
	add_sunspot_column( :pe_leukemic_skin_infiltrates,
		:meth => ->(s){ YNDK[s.pe_leukemic_skin_infiltrates]||'NULL' },
		:facetable => true )
	add_sunspot_column( :pe_lymphadenopathy,
		:meth => ->(s){ YNDK[s.pe_lymphadenopathy]||'NULL' },
		:facetable => true )
	add_sunspot_column( :pe_splenomegaly,
		:meth => ->(s){ YNDK[s.pe_splenomegaly]||'NULL' },
		:facetable => true )
	add_sunspot_column( :pe_splenomegaly_size )
	add_sunspot_column( :pe_hepatomegaly,
		:meth => ->(s){ YNDK[s.pe_hepatomegaly]||'NULL' },
		:facetable => true )
	add_sunspot_column( :pe_hepatomegaly_size )
	add_sunspot_column( :pe_testicular_mass,
		:meth => ->(s){ YNDK[s.pe_testicular_mass]||'NULL' },
		:facetable => true )
	add_sunspot_column( :pe_other_soft_tissue,
		:meth => ->(s){ YNDK[s.pe_other_soft_tissue]||'NULL' },
		:facetable => true )
	add_sunspot_column( :pe_other_soft_tissue_location )
	add_sunspot_column( :pe_other_soft_tissue_size )

	add_sunspot_column( :abstracted_by )
	add_sunspot_column( :abstracted_on )
	add_sunspot_column( :as_other_abnormal_findings )
	add_sunspot_column( :bma_comments )
	add_sunspot_column( :bmb_comments )
	add_sunspot_column( :cct_mediastinal_mass_description )
	add_sunspot_column( :cgs_comments )
	add_sunspot_column( :cgs_conventional_karyotyping_results )
	add_sunspot_column( :cgs_hospital_fish_results )
	add_sunspot_column( :cgs_others )
	add_sunspot_column( :cp_therapeutic_agents )
	add_sunspot_column( :csf_cytology )
	add_sunspot_column( :cxr_mediastinal_mass_description )
	add_sunspot_column( :ds_clinical_diagnosis )
	add_sunspot_column( :em_comments )
	add_sunspot_column( :entry_1_by_uid )
	add_sunspot_column( :entry_2_by_uid )
	add_sunspot_column( :hla_results )
	add_sunspot_column( :marker_comments )
	add_sunspot_column( :merged_by_uid )
	add_sunspot_column( :other_markers )
	add_sunspot_column( :pe_lymphadenopathy_description )
	add_sunspot_column( :pe_neurological_abnormalities )
	add_sunspot_column( :pe_other_abnormal_findings )
	add_sunspot_column( :ploidy_notes )
	add_sunspot_column( :ploidy_other_dna_measurement )
	add_sunspot_column( :reviewed_by )
	add_sunspot_column( :reviewed_on )
	add_sunspot_column( :ts_findings )


	searchable_plus do
		text :patid
		text :subjectid
		text :icf_master_id
		text :vital_status
		text :dob
		text :hospital
		text :diagnosis
		text :phase

		text :as_ascities
		text :as_hepatomegaly
		text :as_lymphadenopathy
		text :as_normal
		text :as_other_abdominal_masses
		text :as_other_abnormal_findings
		text :as_report_found
		text :as_sphenomegaly
		text :as_test_date
		text :bma07_classification
		text :bma07_inconclusive_results
		text :bma07_percentage_of_blasts
		text :bma07_report_found
		text :bma07_test_date
		text :bma14_classification
		text :bma14_inconclusive_results
		text :bma14_percentage_of_blasts
		text :bma14_report_found
		text :bma14_test_date
		text :bma28_classification
		text :bma28_inconclusive_results
		text :bma28_percentage_of_blasts
		text :bma28_report_found
		text :bma28_test_date
		text :bma_comments
		text :bma_percentage_blasts
		text :bma_percentage_blasts_known
		text :bma_report_found
		text :bma_test_date
		text :bmb_comments
		text :bmb_percentage_blasts
		text :bmb_percentage_blasts_known
		text :bmb_report_found
		text :bmb_test_date
		text :cbc_hemoglobin
		text :cbc_leukocyte_count
		text :cbc_number_of_blasts
		text :cbc_percentage_blasts
		text :cbc_platelet_count
		text :cbc_report_found
		text :cbc_test_date
		text :ccs_alpha_naphthyl_butyrate_esterase
		text :ccs_bcl_2
		text :ccs_chloroacetate_esterase
		text :ccs_non_specific_esterase
		text :ccs_other
		text :ccs_periodic_acid_schiff
		text :ccs_peroxidase
		text :ccs_report_found
		text :ccs_sudan_black
		text :ccs_test_date
		text :ccs_toluidine_blue
		text :cct_mediastinal_mass_description
		text :cct_report_found
		text :cct_result
		text :cct_test_date
		text :cgs_comments
		text :cgs_conventional_karyotype_done
		text :cgs_conventional_karyotyping_results
		text :cgs_deletion_16_q22
		text :cgs_deletion_6q
		text :cgs_deletion_9p
		text :cgs_hospital_fish_done
		text :cgs_hospital_fish_results
		text :cgs_hyperdiploidy_by
		text :cgs_hyperdiploidy_detected
		text :cgs_hyperdiploidy_number_of_chromosomes
		text :cgs_inv16
		text :cgs_monosomy_7
		text :cgs_normal
		text :cgs_others
		text :cgs_report_found
		text :cgs_t12_21
		text :cgs_t15_17
		text :cgs_t16_16_p13_q22
		text :cgs_t1_19
		text :cgs_t4_11_q21_q23
		text :cgs_t8_21
		text :cgs_t9_22
		text :cgs_test_date
		text :cgs_trisomy_10
		text :cgs_trisomy_14
		text :cgs_trisomy_17
		text :cgs_trisomy_18
		text :cgs_trisomy_21
		text :cgs_trisomy_4
		text :cgs_trisomy_5
		text :cgs_trisomy_6
		text :cgs_trisomy_8
		text :cgs_trisomy_x
		text :clinical_remission
		text :cp_induction_protocol_name_and_number
		text :cp_induction_protocol_used
		text :cp_report_found
		text :cp_therapeutic_agents
		text :csf_blasts_present
		text :csf_cytology
		text :csf_number_of_blasts
		text :csf_pb_contamination
		text :csf_rbc
		text :csf_report_found
		text :csf_test_date
		text :csf_wbc
		text :cxr_mediastinal_mass_description
		text :cxr_report_found
		text :cxr_result
		text :cxr_test_date
		text :dfc_numerical_data_available
		text :dfc_report_found
		text :dfc_test_date
		text :ds_clinical_diagnosis
		text :ds_report_found
		text :ds_test_date
		text :em_comments
		text :em_report_found
		text :em_test_date
		text :height
		text :height_units
		text :hla_report_found
		text :hla_results
		text :hla_test_date
		text :hpr_down_syndrome_phenotype
		text :hpr_hepatomegaly
		text :hpr_report_found
		text :hpr_splenomegaly
		text :hpr_test_date
		text :icdo_classification_description
		text :icdo_classification_number
		text :leukemia_class
		text :leukemia_lineage
		text :marker_bmk
		text :marker_bml
		text :marker_cd10
		text :marker_cd11b
		text :marker_cd11c
		text :marker_cd13
		text :marker_cd14
		text :marker_cd15
		text :marker_cd16
		text :marker_cd19
		text :marker_cd19_cd10
		text :marker_cd1a
		text :marker_cd2
		text :marker_cd20
		text :marker_cd21
		text :marker_cd22
		text :marker_cd23
		text :marker_cd24
		text :marker_cd25
		text :marker_cd3
		text :marker_cd33
		text :marker_cd34
		text :marker_cd38
		text :marker_cd3_cd4
		text :marker_cd3_cd8
		text :marker_cd4
		text :marker_cd40
		text :marker_cd41
		text :marker_cd45
		text :marker_cd5
		text :marker_cd56
		text :marker_cd57
		text :marker_cd61
		text :marker_cd7
		text :marker_cd71
		text :marker_cd8
		text :marker_cd9
		text :marker_cdw65
		text :marker_comments
		text :marker_glycophorin_a
		text :marker_hla_dr
		text :marker_igm
		text :marker_sig
		text :marker_tdt
		text :ob_liver_date
		text :ob_liver_leukemic_cells_present
		text :ob_liver_report_found
		text :ob_lymph_node_date
		text :ob_lymph_node_leukemic_cells_present
		text :ob_lymph_node_report_found
		text :ob_other_date
		text :ob_other_leukemic_cells_present
		text :ob_other_report_found
		text :ob_other_site_organ
		text :ob_skin_date
		text :ob_skin_leukemic_cells_present
		text :ob_skin_report_found
		text :omg_abnormalities_found
		text :omg_all1
		text :omg_bcr
		text :omg_etv6
		text :omg_fish
		text :omg_p15
		text :omg_p16
		text :omg_p53
		text :omg_ras
		text :omg_test_date
		text :omg_wt1
		text :other_all_leukemia_class
		text :other_aml_leukemia_class
		text :other_markers
		text :pe_gingival_infiltrates
		text :pe_hepatomegaly
		text :pe_hepatomegaly_size
		text :pe_leukemic_skin_infiltrates
		text :pe_lymphadenopathy
		text :pe_lymphadenopathy_description
		text :pe_neurological_abnormalities
		text :pe_other_abnormal_findings
		text :pe_other_soft_tissue
		text :pe_other_soft_tissue_location
		text :pe_other_soft_tissue_size
		text :pe_report_found
		text :pe_splenomegaly
		text :pe_splenomegaly_size
		text :pe_test_date
		text :pe_testicular_mass
		text :ploidy_diploid
		text :ploidy_dna_index
		text :ploidy_found_where
		text :ploidy_hyperdiploid
		text :ploidy_hypodiploid
		text :ploidy_notes
		text :ploidy_other_dna_measurement
		text :ploidy_pseudodiploid
		text :ploidy_report_found
		text :ploidy_test_date
		text :tdt_found_where
		text :tdt_numerical_result
		text :tdt_report_found
		text :tdt_result
		text :tdt_test_date
		text :ts_findings
		text :ts_report_found
		text :ts_test_date
		text :weight
		text :weight_units
	end

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
					self.entry_1_by_uid = current_user_uid||0
					self.entry_2_by_uid = current_user_uid||0
				when 1 
					self.entry_1_by_uid = current_user_uid||0
					self.entry_2_by_uid = current_user_uid||0
				when 2
					abs = study_subject.abstracts
					#	compact just in case a nil crept in
					self.entry_1_by_uid = [abs[0].entry_1_by_uid,abs[0].entry_2_by_uid].compact.first
					self.entry_2_by_uid = [abs[1].entry_1_by_uid,abs[1].entry_2_by_uid].compact.first
					self.merged_by_uid  = current_user_uid||0
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
