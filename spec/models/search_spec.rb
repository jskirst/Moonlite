require 'spec_helper'

describe Search do
  before :each do 
    @search = Search.new
  end

  it "should be" do
    params = { paths: [Path.pluck(:id).to_a] }
  end
end