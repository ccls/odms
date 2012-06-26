pdf.font_size(7.5) do
	pdf.text "CCLS ID: #{@sample.study_subject.subjectid}-#{@sample.sampleid}"
	pdf.move_down 3
	pdf.text "Sample Type: #{@sample.sample_type}"
	pdf.move_down 3
	pdf.text "ICF Master ID: #{@sample.study_subject.icf_master_id_to_s}"
	pdf.move_down 3

	pdf.font_size(22) do
		pdf.font(Rails.root.join("prawn/fonts/3OF9_NEW.TTF").to_s) do
			pdf.text @sample.sampleid
		end
	end
	pdf.move_down 1
	pdf.text @sample.sampleid
end
