class AddLegacyAbstractStringFields < ActiveRecord::Migration

  def up
		add_column :abstracts, :att13, :integer
		add_column :abstracts, :bm1d_14_int, :integer
		add_column :abstracts, :bm1d_28_int, :integer
#		add_column :abstracts, :bm1d_7_int, :string
		add_column :abstracts, :cbf6b, :integer
		add_column :abstracts, :cbf7_old, :string
#		add_column :abstracts, :cc2, :string
#		add_column :abstracts, :cd11b_14, :string
#		add_column :abstracts, :cd11b_7, :string
#		add_column :abstracts, :cd11c_14, :string
#		add_column :abstracts, :cd11c_7, :string
#		add_column :abstracts, :cd16_14, :string
#		add_column :abstracts, :cd16_7, :string
#		add_column :abstracts, :cd1a_7, :string
#		add_column :abstracts, :cd21_14, :string
#		add_column :abstracts, :cd21_7, :string
#		add_column :abstracts, :cd22_14, :string
#		add_column :abstracts, :cd22_7, :string
#		add_column :abstracts, :cd23_14, :string
#		add_column :abstracts, :cd23_7, :string
#		add_column :abstracts, :cd24_14, :string
#		add_column :abstracts, :cd24_7, :string
#		add_column :abstracts, :cd25_14, :string
#		add_column :abstracts, :cd25_7, :string
#		add_column :abstracts, :cd2_7, :string
#		add_column :abstracts, :cd38_14, :string
#		add_column :abstracts, :cd38_7, :string
#		add_column :abstracts, :cd3cd4_14, :string
#		add_column :abstracts, :cd3cd4_7, :string
#		add_column :abstracts, :cd3cd8_14, :string
#		add_column :abstracts, :cd3cd8_7, :string
#		add_column :abstracts, :cd40_14, :string
#		add_column :abstracts, :cd40_7, :string
#		add_column :abstracts, :cd41_14, :string
#		add_column :abstracts, :cd41_7, :string
#		add_column :abstracts, :cd45_14, :string
#		add_column :abstracts, :cd45_7, :string
#		add_column :abstracts, :cd4_7, :string
#		add_column :abstracts, :cd56_7, :string
#		add_column :abstracts, :cd57_14, :string
#		add_column :abstracts, :cd57_7, :string
		add_column :abstracts, :cd5_7, :integer
#		add_column :abstracts, :cd61_7, :string
#		add_column :abstracts, :cd71_14, :string
#		add_column :abstracts, :cd71_7, :string
#		add_column :abstracts, :cd7_7, :string
#		add_column :abstracts, :cd8_7, :string
#		add_column :abstracts, :cd9_14, :string
#		add_column :abstracts, :cd9_7, :string
#		add_column :abstracts, :cdw65_14, :string
#		add_column :abstracts, :cdw65_7, :string
#		add_column :abstracts, :cim8, :string
		add_column :abstracts, :cy3_legacy, :string
		add_column :abstracts, :cy_chrom01, :integer
		add_column :abstracts, :cy_chrom02, :integer
		add_column :abstracts, :cy_compkary, :integer
		add_column :abstracts, :cy_compkaryb, :integer
		add_column :abstracts, :cy_deletion, :integer
		add_column :abstracts, :cy_diag_conv, :integer
		add_column :abstracts, :cy_diag_fish, :integer
		add_column :abstracts, :cy_metaphase01, :integer
		add_column :abstracts, :cy_metaphase02, :integer
		add_column :abstracts, :cy_tri10_fish, :integer
		add_column :abstracts, :cy_tri17_fish, :integer
		add_column :abstracts, :cy_tri21_fish, :integer
		add_column :abstracts, :cy_tri21_pheno_old, :integer
		add_column :abstracts, :cy_tri4_fish, :integer
		add_column :abstracts, :cy_tri5_fish, :integer
#		add_column :abstracts, :cytoigm_14, :string
#		add_column :abstracts, :cytoigm_7, :string
		add_column :abstracts, :diagnosis, :string
		add_column :abstracts, :dischargesummarydate, :datetime
		add_column :abstracts, :dischargesummaryfound, :integer
		add_column :abstracts, :fabclass, :integer
		add_column :abstracts, :fc1c1_backup, :string, :limit => 5
		add_column :abstracts, :fc1c2_backup, :string, :limit => 5
		add_column :abstracts, :fc1l10a, :string
		add_column :abstracts, :fc1l10b, :string, :limit => 5
		add_column :abstracts, :fc1l10c, :string
		add_column :abstracts, :fc1l11a, :string, :limit => 20
		add_column :abstracts, :fc1l11b, :string, :limit => 5
		add_column :abstracts, :fc1l11c, :string, :limit => 5
		add_column :abstracts, :fc1l12a, :string, :limit => 20
		add_column :abstracts, :fc1l12b, :string, :limit => 5
		add_column :abstracts, :fc1l12c, :string, :limit => 20

		add_column :abstracts, :fc1l13a, :string, :limit => 20
		add_column :abstracts, :fc1l13b, :string, :limit => 5
		add_column :abstracts, :fc1l13c, :string, :limit => 5
		add_column :abstracts, :fc1l14a, :string, :limit => 20
		add_column :abstracts, :fc1l14b, :string, :limit => 5
		add_column :abstracts, :fc1l14c, :string, :limit => 20
		add_column :abstracts, :fc1l8a, :string, :limit => 20
		add_column :abstracts, :fc1l8b, :string, :limit => 5
		add_column :abstracts, :fc1l8c, :string, :limit => 20
		add_column :abstracts, :fc1l9a, :string, :limit => 20
		add_column :abstracts, :fc1l9b, :string, :limit => 5
		add_column :abstracts, :fc1l9c, :string, :limit => 20
#		add_column :abstracts, :fsh_hospcomments, :string
#		add_column :abstracts, :fsh_percpos, :string
#		add_column :abstracts, :fsh_ucbpercpos, :string
#		add_column :abstracts, :fsh_ucbprobes, :string
#		add_column :abstracts, :glyca_14, :string
#		add_column :abstracts, :glyca_7, :string
		add_column :abstracts, :icdo, :string, :limit => 10
		add_column :abstracts, :icdo1, :string, :limit => 50
		add_column :abstracts, :icdocodeid_1990, :integer
		add_column :abstracts, :icdocodeid_2000, :integer
		add_column :abstracts, :id1, :string, :limit => 20
		add_column :abstracts, :id2, :string, :limit => 20
		add_column :abstracts, :id3, :string, :limit => 20
		add_column :abstracts, :id4, :string, :limit => 40
		add_column :abstracts, :id5, :string, :limit => 10
		add_column :abstracts, :id7, :datetime
		add_column :abstracts, :nd4a, :string, :limit => 40
		add_column :abstracts, :nd5a, :string, :limit => 20
		add_column :abstracts, :nd6a, :string, :limit => 20
#		add_column :abstracts, :nd6c, :string
#		add_column :abstracts, :other3_7, :string
#		add_column :abstracts, :other4_7, :string
#		add_column :abstracts, :other5_7, :string
#		add_column :abstracts, :pe10a, :string
#		add_column :abstracts, :pe11a, :string
		add_column :abstracts, :pe13, :integer
#		add_column :abstracts, :pe5a, :string
#		add_column :abstracts, :pe6a, :string
		add_column :abstracts, :pe7, :integer
#		add_column :abstracts, :pe7a, :string
#		add_column :abstracts, :pl4, :string
#		add_column :abstracts, :specify3_7, :string
#		add_column :abstracts, :specify4_7, :string
#		add_column :abstracts, :specify5_7, :string
		add_column :abstracts, :sty3g1, :integer
		add_column :abstracts, :sty3h1, :integer
		add_column :abstracts, :sty3i1, :integer
#		add_column :abstracts, :sty3k1, :string
		add_column :abstracts, :sty3l1, :integer
		add_column :abstracts, :sty3m1, :integer
		add_column :abstracts, :sty3n, :string, :limit => 10
		add_column :abstracts, :sty3n1, :integer
		add_column :abstracts, :sty3o, :string, :limit => 10
		add_column :abstracts, :sty3o1, :integer
		add_column :abstracts, :sty3p, :string, :limit => 10
		add_column :abstracts, :sty3p1, :integer
		add_column :abstracts, :sty3q, :string, :limit => 10
		add_column :abstracts, :sty3q1, :integer
		add_column :abstracts, :sty3r, :string, :limit => 10
		add_column :abstracts, :sty3r1, :integer
#		add_column :abstracts, :sty3s, :string
#		add_column :abstracts, :sty3s1, :string
#		add_column :abstracts, :sty3t, :string
#		add_column :abstracts, :sty3t1, :string
#		add_column :abstracts, :sty3u, :string
#		add_column :abstracts, :sty3u1, :string
#		add_column :abstracts, :sty3y, :string
#		add_column :abstracts, :sty3y1, :string
#		add_column :abstracts, :sty3z, :string
#		add_column :abstracts, :sty3z1, :string
#		add_column :abstracts, :sty4a, :string
#		add_column :abstracts, :sty4b, :string
#		add_column :abstracts, :surfimmunog_14, :string
#		add_column :abstracts, :surfimmunog_7, :string
		add_column :abstracts, :verified, :integer
  end

#Mysql2::Error: Row size too large. The maximum row size for the used table type, not counting BLOBs, is 65535. You have to change some columns to TEXT or BLOBs: ALTER TABLE `abstracts` ADD `cy_diag_fish` varchar(255)

  def down
		remove_column :abstracts, :att13
		remove_column :abstracts, :bm1d_14_int
		remove_column :abstracts, :bm1d_28_int
#		remove_column :abstracts, :bm1d_7_int
		remove_column :abstracts, :cbf6b
		remove_column :abstracts, :cbf7_old
#		remove_column :abstracts, :cc2
#		remove_column :abstracts, :cd11b_14
#		remove_column :abstracts, :cd11b_7
#		remove_column :abstracts, :cd11c_14
#		remove_column :abstracts, :cd11c_7
#		remove_column :abstracts, :cd16_14
#		remove_column :abstracts, :cd16_7
#		remove_column :abstracts, :cd1a_7
#		remove_column :abstracts, :cd21_14
#		remove_column :abstracts, :cd21_7
#		remove_column :abstracts, :cd22_14
#		remove_column :abstracts, :cd22_7
#		remove_column :abstracts, :cd23_14
#		remove_column :abstracts, :cd23_7
#		remove_column :abstracts, :cd24_14
#		remove_column :abstracts, :cd24_7
#		remove_column :abstracts, :cd25_14
#		remove_column :abstracts, :cd25_7
#		remove_column :abstracts, :cd2_7
#		remove_column :abstracts, :cd38_14
#		remove_column :abstracts, :cd38_7
#		remove_column :abstracts, :cd3cd4_14
#		remove_column :abstracts, :cd3cd4_7
#		remove_column :abstracts, :cd3cd8_14
#		remove_column :abstracts, :cd3cd8_7
#		remove_column :abstracts, :cd40_14
#		remove_column :abstracts, :cd40_7
#		remove_column :abstracts, :cd41_14
#		remove_column :abstracts, :cd41_7
#		remove_column :abstracts, :cd45_14
#		remove_column :abstracts, :cd45_7
#		remove_column :abstracts, :cd4_7
#		remove_column :abstracts, :cd56_7
#		remove_column :abstracts, :cd57_14
#		remove_column :abstracts, :cd57_7
		remove_column :abstracts, :cd5_7
#		remove_column :abstracts, :cd61_7
#		remove_column :abstracts, :cd71_14
#		remove_column :abstracts, :cd71_7
#		remove_column :abstracts, :cd7_7
#		remove_column :abstracts, :cd8_7
#		remove_column :abstracts, :cd9_14
#		remove_column :abstracts, :cd9_7
#		remove_column :abstracts, :cdw65_14
#		remove_column :abstracts, :cdw65_7
#		remove_column :abstracts, :cim8
		remove_column :abstracts, :cy3_legacy
		remove_column :abstracts, :cy_chrom01
		remove_column :abstracts, :cy_chrom02
		remove_column :abstracts, :cy_compkary
		remove_column :abstracts, :cy_compkaryb
		remove_column :abstracts, :cy_deletion
		remove_column :abstracts, :cy_diag_conv
		remove_column :abstracts, :cy_diag_fish
		remove_column :abstracts, :cy_metaphase01
		remove_column :abstracts, :cy_metaphase02
		remove_column :abstracts, :cy_tri10_fish
		remove_column :abstracts, :cy_tri17_fish
		remove_column :abstracts, :cy_tri21_fish
		remove_column :abstracts, :cy_tri21_pheno_old
		remove_column :abstracts, :cy_tri4_fish
		remove_column :abstracts, :cy_tri5_fish
#		remove_column :abstracts, :cytoigm_14
#		remove_column :abstracts, :cytoigm_7
		remove_column :abstracts, :diagnosis
		remove_column :abstracts, :dischargesummarydate
		remove_column :abstracts, :dischargesummaryfound
		remove_column :abstracts, :fabclass
		remove_column :abstracts, :fc1c1_backup
		remove_column :abstracts, :fc1c2_backup
		remove_column :abstracts, :fc1l10a
		remove_column :abstracts, :fc1l10b
		remove_column :abstracts, :fc1l10c
		remove_column :abstracts, :fc1l11a
		remove_column :abstracts, :fc1l11b
		remove_column :abstracts, :fc1l11c
		remove_column :abstracts, :fc1l12a
		remove_column :abstracts, :fc1l12b
		remove_column :abstracts, :fc1l12c

		remove_column :abstracts, :fc1l13a
		remove_column :abstracts, :fc1l13b
		remove_column :abstracts, :fc1l13c
		remove_column :abstracts, :fc1l14a
		remove_column :abstracts, :fc1l14b
		remove_column :abstracts, :fc1l14c
		remove_column :abstracts, :fc1l8a
		remove_column :abstracts, :fc1l8b
		remove_column :abstracts, :fc1l8c
		remove_column :abstracts, :fc1l9a
		remove_column :abstracts, :fc1l9b
		remove_column :abstracts, :fc1l9c
#		remove_column :abstracts, :fsh_hospcomments
#		remove_column :abstracts, :fsh_percpos
#		remove_column :abstracts, :fsh_ucbpercpos
#		remove_column :abstracts, :fsh_ucbprobes
#		remove_column :abstracts, :glyca_14
#		remove_column :abstracts, :glyca_7
		remove_column :abstracts, :icdo
		remove_column :abstracts, :icdo1
		remove_column :abstracts, :icdocodeid_1990
		remove_column :abstracts, :icdocodeid_2000
		remove_column :abstracts, :id1
		remove_column :abstracts, :id2
		remove_column :abstracts, :id3
		remove_column :abstracts, :id4
		remove_column :abstracts, :id5
		remove_column :abstracts, :id7
		remove_column :abstracts, :nd4a
		remove_column :abstracts, :nd5a
		remove_column :abstracts, :nd6a
#		remove_column :abstracts, :nd6c
#		remove_column :abstracts, :other3_7
#		remove_column :abstracts, :other4_7
#		remove_column :abstracts, :other5_7
#		remove_column :abstracts, :pe10a
#		remove_column :abstracts, :pe11a
		remove_column :abstracts, :pe13
#		remove_column :abstracts, :pe5a
#		remove_column :abstracts, :pe6a
		remove_column :abstracts, :pe7
#		remove_column :abstracts, :pe7a
#		remove_column :abstracts, :pl4
#		remove_column :abstracts, :specify3_7
#		remove_column :abstracts, :specify4_7
#		remove_column :abstracts, :specify5_7
		remove_column :abstracts, :sty3g1
		remove_column :abstracts, :sty3h1
		remove_column :abstracts, :sty3i1
#		remove_column :abstracts, :sty3k1
		remove_column :abstracts, :sty3l1
		remove_column :abstracts, :sty3m1
		remove_column :abstracts, :sty3n
		remove_column :abstracts, :sty3n1
		remove_column :abstracts, :sty3o
		remove_column :abstracts, :sty3o1
		remove_column :abstracts, :sty3p
		remove_column :abstracts, :sty3p1
		remove_column :abstracts, :sty3q
		remove_column :abstracts, :sty3q1
		remove_column :abstracts, :sty3r
		remove_column :abstracts, :sty3r1
#		remove_column :abstracts, :sty3s
#		remove_column :abstracts, :sty3s1
#		remove_column :abstracts, :sty3t
#		remove_column :abstracts, :sty3t1
#		remove_column :abstracts, :sty3u
#		remove_column :abstracts, :sty3u1
#		remove_column :abstracts, :sty3y
#		remove_column :abstracts, :sty3y1
#		remove_column :abstracts, :sty3z
#		remove_column :abstracts, :sty3z1
#		remove_column :abstracts, :sty4a
#		remove_column :abstracts, :sty4b
#		remove_column :abstracts, :surfimmunog_14
#		remove_column :abstracts, :surfimmunog_7
		remove_column :abstracts, :verified
  end

#Mysql2::Error: Row size too large. The maximum row size for the used table type, not counting BLOBs, is 65535. You have to change some columns to TEXT or BLOBs: ALTER TABLE `abstracts` ADD `cy_diag_fish` varchar(255)

end
