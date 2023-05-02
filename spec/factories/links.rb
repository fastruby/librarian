FactoryBot.define do
  factory :link do
    url {'https://www.fastruby.io/blog/rails/upgrades/7-common-mistakes-made-while-doing-rails-upgrades.html' }
    title {'7 common mistakes'}
    description {''}
    open_graph_description {""}
    published_at {Date.yesterday}		
  end
end