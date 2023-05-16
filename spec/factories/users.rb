FactoryBot.define do
  factory :user do
    email { 'hello@ombulabs.com' }
    password { '123456' }
    name { 'John Smith' }
  end
end
