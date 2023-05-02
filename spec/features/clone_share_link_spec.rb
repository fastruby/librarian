require "rails_helper"

describe "Clone share link", js: true do
    context "when user is not authenticated" do
    end

    context "when user is authenticated" do
        before do 
            link = Link.create!(url: "https://www.fastruby.io/blog/rails/upgrades/7-common-mistakes-made-while-doing-rails-upgrades.html", published_at: Date.yesterday)
            share = link.shares.create!(shortened_url: "https://go.fastruby.io/6as",                              
            utm_source: "LinkedIn",                                                   
            utm_medium: "community",                                                  
            utm_campaign: "campaignOne",                                              
            utm_term: "termOne",                                                  
            utm_content: "campaignContent")

            visit "/links/#{link.id}/shares/#{share.id}/clone"
            byebug
        end

        it "ensures that there are shares" do
        end

        it "ensures there's a clone button after the share" do
        end

        it "ensures that clone takes you to a new page with the cloned information" do
        end


    end
end