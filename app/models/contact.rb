class Contact < ActiveRecord::Base
  # :user_id, :owner_id
  # :purchased_at, :paid_at, :contacted_at, :responsed_at
  # :response, :response_status, :amount_paid
  
  belongs_to :user
  belongs_to :owner, class_name: "User"
  
  validates :user_id, :purchased_at, presence: true
end