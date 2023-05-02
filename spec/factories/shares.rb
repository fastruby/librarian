FactoryBot.define do
  factory :share do
    utm_source { 'LinkedIn' }
    utm_medium { 'community' }
    utm_campaign { 'campaignOne' }
    utm_term { 'termOne' }
    utm_content { 'campaignContent' }
    link
  end
end
