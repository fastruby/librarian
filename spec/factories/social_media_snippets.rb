FactoryBot.define do
  factory :social_media_snippet do
    social_media_type { 'LinkedIn' }
    sequence(:content) { |n| "Snippet copy ##{n}" }
    link
  end
end
