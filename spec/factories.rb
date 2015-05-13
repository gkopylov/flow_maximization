#encoding: utf-8

FactoryGirl.define do
  factory :user, :class => 'User' do
    sequence(:email) { |n| "user_numero_#{ n }@mail.com" }

    password 'testpassword'

    password_confirmation 'testpassword'
  end

  factory :project do
    sequence(:name) { |n| "project_numero_#{ n }" }
  
    user
  end

  factory :node do
    project
  end

  factory :connection do
    capacity 10

    source { create :node }

    target { create :node }
  end

  factory :request do
    size 10
    sequence(:source_id) { |n| n }
    sequence(:target_id) { |n| n + 1 }
    lifetime 1

    project
  end
  
  factory :timer do
    project_id 1
    time 1
    capacities_matrix_text "MyText"
  end
end
