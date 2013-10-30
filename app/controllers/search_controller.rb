require 'carmen'
class SearchController < ApplicationController
  before_filter :authenticate
  before_filter { raise "ACCESS DENIED" unless @enable_administration }
  
  def new
    @group = @admin_group
    @group_custom_style = @group.custom_style if @group
    @search = Search.new
    @paths = Path.where.not(professional_at: nil)
    user_states = User.pluck(:state).uniq.compact
    user_countries = User.pluck(:country).uniq.compact.collect
    @countries = Carmen::Country.all.collect do |c| 
      if user_countries.include?(c.code)
        code = c.code
        name = c.name
        subregions = c.subregions.collect do |sr| 
          if user_states.include?(sr.code)
            [sr.name, sr.code]
          end
        end
        if subregions.empty?
          nil
        else
          { code: c.code, name: c.name, subregions: subregions.compact }
        end
      end
    end
    @countries.compact!
  end
  
  def create
    search = Search.new
    @results = search.submit(params[:search])
    render partial: "search/results"
  end
  
  def subregion
  end
  
  private
  
  include Carmen
  
end