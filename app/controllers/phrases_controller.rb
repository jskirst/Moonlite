class PhrasesController < ApplicationController
  before_filter :authenticate
  before_filter :admin_only
  
  def new
    @phrase = Phrase.new
  end
  
  def create
    phrases = params[:phrase][:content].split(",")
    if PhrasePairing.create_phrase_pairings(phrases)
      flash[:success] = "Phrases recorded."
    else
      flash[:error] = "Unknown error prevent phrase recording."
    end
    @phrase = Phrase.new
    render "new"
  end
  
  private
    def admin_only
      redirect_to(root_path) unless (current_user.admin?)
    end
end