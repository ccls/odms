module GiftCardsHelper

	def gift_card_id_bar(gift_card,&block)
		stylesheets('subject_id_bar')
		content_for :main do
			"<div id='id_bar'>\n" <<
			"<div class='number'>\n" <<
			"<span>Card Number:</span>\n" <<
			"<span>#{gift_card.number}</span>\n" <<
			"</div><!-- class='number' -->\n" <<
			"<div class='controls'>\n" <<
#			content_for(:id_bar).to_s <<
			@content_for_id_bar.to_s <<
			((block_given?)?yield: '') <<
			"</div><!-- class='controls' -->\n" <<
			"</div><!-- id='id_bar' -->\n"
		end
	end

end
