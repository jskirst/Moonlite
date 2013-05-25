FactoryGirl.define do
  factory :company do |company|
    company.name "MetaBright"
  end

  factory :user_role do |r|
    r.association :company
    r.name  "Admin"
    r.enable_administration  "t"
  end

  factory :user, :aliases => [:creator] do
    name
    username
    email
    password "testpassword"
    password_confirmation "testpassword"
    association :company
    association :user_role
  end

  factory :path do
    name Faker::Lorem.sentence(1)
    description Faker::Lorem.sentence(12)
    association :user
  end

  factory :section do |f|
    name Faker::Lorem.sentence(1)
    association :path
  end
  
  factory :task do
    question Faker::Lorem.sentence(1)
    answer_type 0
    answer_sub_type 100
    association :section
    association :creator
  end
  
  factory :submitted_answer do
    content Faker::Lorem.sentence(1)
    association :task
  end

  factory :completed_task do
    association :task
    association :user
    status_id 1
    association :submitted_answer
  end
  
  factory :enrollment do
    association :path
    association :user
  end

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :name do |n|
    "name#{n}"
  end
  
  sequence :username do |n|
    "username#{n}"
  end
end