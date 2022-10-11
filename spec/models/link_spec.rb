require "rails_helper"

RSpec.describe Link do
  describe "#valid?" do
    context "when it does not have a url" do
      it "is not valid" do
        link = Link.new
        
        expect(link.valid?).to be_falsey
        expect(link.errors.full_messages).to eq ["Url is invalid"]
      end
    end
  end
end