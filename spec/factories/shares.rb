FactoryBot.define do
  factory :share do
    utm_source { 'LinkedIn' }
    utm_medium { 'Organic' }
    utm_campaign { 'Blogpromo' }
    utm_term { 'termOne' }
    utm_content { 'Photo' }
    link
  end
end
