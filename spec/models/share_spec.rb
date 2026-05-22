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

    context "on create with HubSpot as utm_source" do
      it "is valid" do
        share = build(:share, utm_source: "HubSpot")

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

    context "on create with PaidSocial as utm_medium" do
      it "is valid" do
        share = build(:share, utm_medium: "PaidSocial")

        expect(share.valid?(:create)).to be_truthy
      end
    end

    context "on create with CPC as utm_medium" do
      it "is valid" do
        share = build(:share, utm_medium: "CPC")

        expect(share.valid?(:create)).to be_truthy
      end
    end

    context "on create with Email as utm_medium" do
      it "is valid" do
        share = build(:share, utm_medium: "Email")

        expect(share.valid?(:create)).to be_truthy
      end
    end

    context "on create with Newsletter as utm_medium" do
      it "is valid" do
        share = build(:share, utm_medium: "Newsletter")

        expect(share.valid?(:create)).to be_truthy
      end
    end

    context "on create with an unrecognized utm_campaign" do
      it "is not valid" do
        share = build(:share, utm_campaign: "campaignOne")

        expect(share.valid?(:create)).to be_falsey
        expect(share.errors[:utm_campaign]).to include("is not included in the list")
      end
    end

    context "on create with LinkedIn-TLA as utm_campaign" do
      it "is valid" do
        share = build(:share, utm_campaign: "LinkedIn-TLA")

        expect(share.valid?(:create)).to be_truthy
      end
    end

    context "on create with LinkedIn-Roadmap-Test as utm_campaign" do
      it "is valid" do
        share = build(:share, utm_campaign: "LinkedIn-Roadmap-Test")

        expect(share.valid?(:create)).to be_truthy
      end
    end

    context "on create with Rails-Upgrade-Guide as utm_campaign" do
      it "is valid" do
        share = build(:share, utm_campaign: "Rails-Upgrade-Guide")

        expect(share.valid?(:create)).to be_truthy
      end
    end

    context "on create with Newsletter as utm_campaign" do
      it "is valid" do
        share = build(:share, utm_campaign: "Newsletter")

        expect(share.valid?(:create)).to be_truthy
      end
    end

    context "on create with Re-engagement as utm_campaign" do
      it "is valid" do
        share = build(:share, utm_campaign: "Re-engagement")

        expect(share.valid?(:create)).to be_truthy
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
