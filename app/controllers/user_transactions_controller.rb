class UserTransactionsController < ApplicationController
  before_filter :authenticate
  before_filter :admin_only
  
  def index
    @user_transactions = UserTransaction.paginate(:page => params[:page])
    @title = "All transactions"
  end
  
  def show
    @user_transaction = UserTransaction.find(params[:id])
    if @user_transaction.nil?
      redirect_to user_transactions_path
    else
      @title = "Transaction #"+@user_transaction.id.to_s
    end
  end
  
  def edit
    @user_transaction = UserTransaction.find(params[:id])
    @title = "Edit Transaction #"+@user_transaction.id.to_s
  end
  
  def update
    @user_transaction = UserTransaction.find(params[:id])
    if @user_transaction.update_attributes(:status => params[:user_transaction][:status])
      flash[:success] = "Profile successfully updated."
      redirect_to user_transactions_path
    else
      @title = "Edit Transaction #"+@user_transaction.id.to_s
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