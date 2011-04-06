class Followup::GiftCardsController < ApplicationController

	resourceful :update_redirect => :update_redirect_path

	def index
		record_or_recall_sort_order
#		if params[:commit] && params[:commit] == 'download'
#			params[:paginate] = false
#		end
#		@subjects = Subject.for_hx_followup(params)
#		if params[:commit] && params[:commit] == 'download'
#			params[:format] = 'csv'
#			headers["Content-disposition"] = "attachment; " <<
#				"filename=subjects_#{Time.now.to_s(:filename)}.csv" 
#			render :template => "subjects/index"
#		end
	end

	def edit
		@subjects  = []
		@subjects += [@gift_card.subject] unless @gift_card.subject.nil?
		@subjects += Subject.need_gift_card({:paginate => false})
	end

protected

	def get_all
		@gift_cards = GiftCard.search(params)
	end

	def update_redirect_path
		followup_gift_card_path(@gift_card)
	end

end
