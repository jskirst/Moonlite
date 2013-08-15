FactoryGirl.define do
  factory :company do
    name                    "MetaBright"
  end

  factory :user_role do
    name                    "Admin"
    enable_administration   "t"
    association :company
  end

  factory :user, :aliases => [:creator] do
    name                    { Faker::Name.name }
    username                { name.gsub(/[^a-z]/, '') }
    email                   { Faker::Internet.email }
    password                "testpassword"
    password_confirmation   "testpassword"
    association :company
    association :user_role
  end

  factory :path do
    name                    { Faker::Name.name }
    permalink               { name.gsub(/[^a-z]/, '') }
    description             { Faker::Lorem.sentence(12) }
    approved_at             { Time.now() }
    promoted_at             { Time.now() }
    professional_at         { Time.now() }
    association :user
  end

  factory :section do
    name                    { Faker::Lorem.sentence(1) }
    association :path
  end
  
  factory :task do
    question                { Faker::Lorem.sentence(1) }
    answer_type             0
    answer_sub_type         100
    association :path
    association :section
    association :creator
  end
  
  factory :submitted_answer do
    content                 { Faker::Lorem.sentence(1) }
    association :task
  end

  factory :completed_task do
    status_id               1
    association :enrollment
    association :task
    association :user
    association :submitted_answer
  end
  
  factory :enrollment do
    association :path
    association :user
  end
  
  factory :group do
    name                    { Faker::Lorem.sentence(1) }
    creator_email           { Faker::Internet.email }
    creator_name            { Faker::Name.name }
    creator_password        { Faker::Internet.password }
    plan_type               "two_to_five"
    stripe_token            "alskdjfalsdf"
    
    before(:create) do
      create(:company)
    end
  end
  
  factory :evaluation do
    company                 { Faker::Name.name }
    title                   { Faker::Name.name }
    selected_paths          { Hash[*Path.all.collect{ |p| [p.id, true] }.flatten] }
    association :group
    association :user
  end
  
  factory :evaluation_enrollment do
    submitted_at            { Time.now() }
    association :evaluation
    association :user
  end
end