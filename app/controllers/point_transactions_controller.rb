class PointTransactionsController < ApplicationController
	before_filter :authenticate
	before_filter :admin_only
	
	def index
		@point_transactions = PointTransaction.paginate(:page => params[:page])
		@title = "All transactions"
	end
	
	def show
		@point_transaction = PointTransaction.find(params[:id])
		if @point_transaction.nil?
			redirect_to point_transactions_path
		else
			@title = "Point Transaction #"+@point_transaction.id.to_s
		end
	end
	
	def edit
		@point_transaction = PointTransaction.find(params[:id])
		@title = "Edit Point Transaction #"+@point_transaction.id.to_s
	end
	
	def update
		@point_transaction = PointTransaction.find(params[:id])
		if @point_transaction.update_attributes(:status => params[:point_transaction][:status])
			flash[:success] = "Profile successfully updated."
			redirect_to point_transactions_path
		else
			@title = "Edit Point Transaction #"+@point_transaction.id.to_s
			render 'edit'
		end
	end
	
	private
		def admin_only
			if !current_user.admin?
				flash[:error] = "You do not have sufficient privaledges to access that page."
				redirect_to root_path
			end
		end
end