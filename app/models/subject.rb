#if g = Gem.source_index.find_name('ccls-ccls_engine').last
#require 'ccls_engine'
#require g.full_gem_path + '/app/models/subject'
#end

#class Subject::NotTwoResponseSets < StandardError; end

#Subject.class_eval do
class Subject < Ccls::Subject
class NotTwoResponseSets < StandardError; end

	with_options :foreign_key => 'study_subject_id' do |f|
		f.has_many :response_sets
		f.has_many :survey_invitations
	end

	def response_sets_the_same?
		if response_sets.length == 2
			#	response_sets.inject(:is_the_same_as?) was nice
			#	but using inject is ruby >= 1.8.7
			return response_sets[0].is_the_same_as?(response_sets[1])
		else
			raise Subject::NotTwoResponseSets
		end
	end

	def response_set_diffs
		if response_sets.length == 2
			#	response_sets.inject(:diff) was nice
			#	but using inject is ruby >= 1.8.7
			return response_sets[0].diff(response_sets[1])
		else
			raise Subject::NotTwoResponseSets
		end
	end

	def recreate_survey_invitation(survey)
		SurveyInvitation.destroy_all( 
			:study_subject_id => self.id,
			:survey_id  => survey.id 
		)
		self.survey_invitations.create(
			:survey_id => survey.id
		)
	end

	def her_invitation
		if survey = Survey.find_by_access_code('home_exposure_survey')
			self.survey_invitations.find_by_survey_id(survey.id)
		end
	end

end
