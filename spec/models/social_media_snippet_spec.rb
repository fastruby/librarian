require "rails_helper"

RSpec.describe SocialMediaSnippet do
  describe "#valid?" do
    context "when it does not have content or link" do
      it "is not valid" do
        link = SocialMediaSnippet.new

        expect(link.valid?).to be_falsey
        expect(link.errors.full_messages).to eq [
          "Link must exist",
          "Content can't be blank",
          "Social media type can't be blank"
        ]
      end
    end

    context "social_media_type" do
      let(:link) { FactoryBot.create(:link) }

      it "accepts each supported type" do
        SocialMediaSnippet::SOCIAL_MEDIA_TYPES.each do |type|
          snippet = SocialMediaSnippet.new(link: link, content: "Copy for #{type}", social_media_type: type)
          expect(snippet).to be_valid, "expected #{type} to be valid"
        end
      end

      it "is case sensitive" do
        snippet = SocialMediaSnippet.new(link: link, content: "Copy", social_media_type: "linkedin")

        expect(snippet).not_to be_valid
        expect(snippet.errors.full_messages).to eq ["Social media type is not included in the list"]
      end

      it "does not block editing a snippet saved before the list existed" do
        legacy = SocialMediaSnippet.new(link: link, content: "Old copy", social_media_type: "Facebook")
        legacy.save!(validate: false)

        expect(legacy.update(content: "Edited old copy")).to be true
      end
    end

    context "duplicates" do
      let(:link) { FactoryBot.create(:link) }
      let!(:existing) { FactoryBot.create(:social_media_snippet, link: link, social_media_type: "LinkedIn", content: "Same copy") }

      it "rejects the same content for the same link and type" do
        duplicate = SocialMediaSnippet.new(link: link, social_media_type: "LinkedIn", content: "Same copy")

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:content]).to eq ["has already been saved for this link and social media type"]
      end

      it "allows the same content for another type" do
        expect(SocialMediaSnippet.new(link: link, social_media_type: "Bluesky", content: "Same copy")).to be_valid
      end

      it "allows the same content for another link" do
        other = FactoryBot.create(:link, url: "https://www.fastruby.io/blog/other.html")

        expect(SocialMediaSnippet.new(link: other, social_media_type: "LinkedIn", content: "Same copy")).to be_valid
      end
    end

    context "share" do
      let(:link) { FactoryBot.create(:link) }

      it "is optional" do
        expect(SocialMediaSnippet.new(link: link, social_media_type: "LinkedIn", content: "Copy")).to be_valid
      end

      it "must belong to the same link" do
        other_share = FactoryBot.create(:share, link: FactoryBot.create(:link, url: "https://www.fastruby.io/blog/other.html"))
        snippet = SocialMediaSnippet.new(link: link, social_media_type: "LinkedIn", content: "Copy", share: other_share)

        expect(snippet).not_to be_valid
        expect(snippet.errors[:share]).to eq ["must belong to the same link"]
      end

      it "must exist when a share_id is given" do
        snippet = SocialMediaSnippet.new(link: link, social_media_type: "LinkedIn", content: "Copy", share_id: 0)

        expect(snippet).not_to be_valid
        expect(snippet.errors[:share]).to eq ["must exist"]
      end

      it "is nullified, not blocked, when the share is destroyed" do
        share = FactoryBot.create(:share, link: link)
        snippet = FactoryBot.create(:social_media_snippet, link: link, share: share)

        expect { share.destroy }.to change(Share, :count).by(-1)
        expect(snippet.reload.share_id).to be_nil
      end
    end
  end
end
