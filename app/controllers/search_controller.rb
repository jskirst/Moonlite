require 'carmen'
class SearchController < ApplicationController
  before_filter :authenticate
  before_filter { raise "ACCESS DENIED" unless @enable_administration }
  
  def new
    @search = Search.new
    @paths = Persona.find_by_name("Hacker").paths
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
  
  def results
    search = Search.new
    @results = search.submit(params[:search])
    render partial: "search/results"
  end
  
  def subregion
  end
  
  private
  
  include Carmen
  
end