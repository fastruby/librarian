require "rails_helper"

RSpec.describe "links/show", type: :view do
  let(:link) { FactoryBot.create(:link) }

  def render_page
    assign(:link, link)
    assign(:grouped_social_media_snippets, link.social_media_snippets.group_by(&:social_media_type))
    render
  end

  context "with snippets" do
    before do
      FactoryBot.create(:social_media_snippet, link: link, social_media_type: "LinkedIn", content: "Copy for LinkedIn")
      FactoryBot.create(:social_media_snippet, link: link, social_media_type: "Mastodon", content: "Copy for Mastodon")
    end

    it "lists each snippet under its social media type" do
      render_page

      expect(rendered).to include("Social Media Snippets", "LinkedIn", "Copy for LinkedIn", "Mastodon", "Copy for Mastodon")
    end

    it "doesn't say where the copy came from, since it isn't only generated anymore" do
      render_page

      expect(rendered).not_to match(/open ?ai/i)
      expect(rendered).to include("Suggested copy for posting this article. Pair each snippet with one of the shortened links above.")
    end
  end

  it "leaves out the section when the link has no snippets" do
    render_page

    expect(rendered).not_to include("Social Media Snippets")
  end
end
