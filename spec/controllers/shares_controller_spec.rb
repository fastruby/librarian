require "rails_helper"

describe SharesController, type: :controller do
    # Maybe add a test in here because we should test whether it's authenticated or not
    
    describe "GET #clone" do
        link = Link.create!(url: "https://www.fastruby.io/blog/rails/upgrades/7-common-mistakes-made-while-doing-rails-upgrades.html", published_at: Date.yesterday)
        share = link.shares.create!(shortened_url: "https://go.fastruby.io/6as",                              
        utm_source: "LinkedIn",                                                   
        utm_medium: "community",                                                  
        utm_campaign: "campaignOne",                                              
        utm_term: "termOne",                                                  
        utm_content: "campaignContent")

        it "returns ok" do
            get :clone, params: { id: share.id, link_id: link.id }
            expect(response).to be_ok
        end
    end
end