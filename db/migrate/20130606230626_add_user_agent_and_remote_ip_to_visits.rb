class AddUserAgentAndRemoteIpToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :user_agent, :string
    add_column :visits, :remote_ip, :string
  end
end
