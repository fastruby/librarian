require "rails_helper"

RSpec.describe SocialMediaSnippet do
  describe "#valid?" do
    context "when it does not have content or link" do
      it "is not valid" do
        link = SocialMediaSnippet.new

        expect(link.valid?).to be_falsey
        expect(link.errors.full_messages).to eq ["Link must exist", "Content can't be blank"]
      end
    end
  end
end