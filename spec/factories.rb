FactoryGirl.define do
  factory :user, :aliases => [:creator] do
    name                    { Faker::Name.name }
    username                { name.gsub(/[^a-z]/, '') }
    email                   { Faker::Internet.email }
    password                "a1b2c3d4"
    password_confirmation   "a1b2c3d4"
    enable_administration   true
  end
  
  factory :persona do
    name                    { Faker::Name.name }
    description             { Faker::Lorem.sentence(12) }
    image_url               { "http://www.example.com" }
    
    factory :persona_with_paths do
      after(:create) do |persona| 
        3.times do 
          create(:path_persona, persona: persona)
        end
      end
    end
  end

  factory :path do
    name                    { Faker::Name.name }
    permalink               { name.gsub(/[^a-z]/, '') }
    description             { Faker::Lorem.sentence(12) }
    approved_at             { Time.now }
    promoted_at             { Time.now }
    professional_at         { Time.now }
    published_at            { Time.now }
    public_at               { Time.now }
    association :user
    
    factory :path_with_tasks do
      after(:create) do |p|
        s = create(:section, path: p)
        21.times { create(:multiple_choice_task, path: p, section: s, creator: p.user) }
        3.times { create(:creative_response_task, path: p, section: s, creator: p.user) }
        create(:path_persona, path: p, persona: (Persona.first || create(:persona)))
      end
    end
  end
  
  factory :path_persona do
    association :persona
    association :path
  end

  factory :section do
    name                    { Faker::Lorem.sentence(1) }
    published_at            { Time.now }
    association :path
  end
  
  factory :task do
    question                { Faker::Lorem.sentence(1) }
    association :path
    association :section
    association :creator
    
    factory :multiple_choice_task do
      answer_type           2
      answer_sub_type       nil
      after(:create) do |t|
        create(:correct_answer, task: t)
        3.times { create(:incorrect_answer, task: t) }
      end
    end
    
    factory :creative_response_task do
      answer_type             0
      answer_sub_type         100
    end
  end
  
  factory :answer do
    content                 { Faker::Lorem.sentence(1) }
    association :task
    
    factory :correct_answer do
      is_correct            true
    end
    
    factory :incorrect_answer do
      is_correct            false
    end
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