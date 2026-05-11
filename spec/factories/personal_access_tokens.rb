FactoryBot.define do
  factory :personal_access_token do
    sequence(:name) { |n| "Token ##{n}" }
    user
  end
end
