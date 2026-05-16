require "rails_helper"

RSpec.describe Share do
  before do
    allow_any_instance_of(Link).to receive(:fetch_social_media_snippets).and_return([])
  end

  describe "#valid?" do
    context "when it does not have a link or the minimum requirements" do
      it "is not valid" do
        link = Share.new

        expect(link.valid?).to be_falsey
        expect(link.errors.full_messages).to eq ["Link must exist", "Utm source can't be blank", "Utm campaign can't be blank", "Utm medium can't be blank", "Utm term can't be blank"]
      end
    end

    context "on create with an unrecognized utm_source" do
      it "is not valid" do
        share = build(:share, utm_source: "NotARealSource")

        expect(share.valid?(:create)).to be_falsey
        expect(share.errors[:utm_source]).to include("is not included in the list")
      end
    end

    context "on create with Bluesky as utm_source" do
      it "is valid" do
        share = build(:share, utm_source: "Bluesky")

        expect(share.valid?(:create)).to be_truthy
      end
    end

    context "on create with an unrecognized utm_medium" do
      it "is not valid" do
        share = build(:share, utm_medium: "community")

        expect(share.valid?(:create)).to be_falsey
        expect(share.errors[:utm_medium]).to include("is not included in the list")
      end
    end

    context "on create with an unrecognized utm_campaign" do
      it "is not valid" do
        share = build(:share, utm_campaign: "campaignOne")

        expect(share.valid?(:create)).to be_falsey
        expect(share.errors[:utm_campaign]).to include("is not included in the list")
      end
    end

    context "on create with an unrecognized utm_content" do
      it "is not valid" do
        share = build(:share, utm_content: "Custom")

        expect(share.valid?(:create)).to be_falsey
        expect(share.errors[:utm_content]).to include("is not included in the list")
      end
    end

    context "when updating an existing record whose utm_source is no longer in the list" do
      it "is allowed (validations are :create-only)" do
        share = create(:share)
        share.update_column(:utm_source, "LegacyValue")

        share.shortened_url = "https://example.com/abc"
        expect(share.save).to be_truthy
      end
    end
  end
end
