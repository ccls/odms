#
#
#		Converted document_versions to yml so this is now unnecessary.
#
#
#namespace :app do
#namespace :document_versions do
#
#	task :destroy_all => :environment do
#		DocumentVersion.destroy_all
#	end
#
#	task :import_all => :destroy_all do
#		#	DO NOT COMMENT OUT THE HEADER LINE OR IT RAISES CRYPTIC ERROR
#		(f=CSV.open("production/fixtures/document_versions.csv", 
#				'rb',{ :headers => true })).each do |line|
#			puts "Processing line #{f.lineno}"
#			puts line
##  1 id,document_type_id,title,language_id,indicator,began_use_on,ended_use_on
##152,1,CHOC-11152010-eng,1,10/18/2011,11/15/2010,10/18/2011
##154 153,1,CCLS-control-eng,1,,,
#
#			dv = DocumentVersion.create! do |d|
#				d.id = line['id']
#				d.document_type_id = line['document_type_id']
#				d.title = line['title']
#				d.language_id = line['language_id']
#				#	indicator is currently a string in the database, but date in csv
#				d.indicator = line['indicator']
#				d.began_use_on = line['began_use_on']
#				d.ended_use_on = line['ended_use_on']
#			end
#			dv.reload
##	use to_i on line when attribute will always be there
##	use to_s on field when attribute may be blank so don't convert to 0
#			raise "DocumentVersion id mismatch." if(
#				dv.id != line['id'].to_i )
#			raise "DocumentVersion document_type_id mismatch." if(
#				dv.document_type_id.to_s != line['document_type_id'] )
#			raise "DocumentVersion title mismatch." if(
#				dv.title != line['title'] )
#			raise "DocumentVersion language_id mismatch." if(
#				dv.language_id.to_s != line['language_id'] )
#			raise "DocumentVersion indicator mismatch:"<<
#				"#{dv.indicator}:#{line['indicator']}" if(
#				dv.indicator != line['indicator'] )
#			if line['began_use_on']
#				raise "DocumentVersion began_use_on mismatch:"<<
#					"#{dv.began_use_on}:#{line['began_use_on']}" if(
#					dv.began_use_on.to_date != line['began_use_on'].to_date )
#			end
#			if line['ended_use_on']
#				raise "DocumentVersion ended_use_on mismatch:"<<
#					"#{dv.ended_use_on}:#{line['ended_use_on']}" if(
#					dv.ended_use_on.to_date != line['ended_use_on'].to_date )
#			end
#		end
#	end
#
#end
#end
