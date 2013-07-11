class FakeAbstractsController < ApplicationController
	def create
		redirect_to new_fake_abstract_path
	end
end
