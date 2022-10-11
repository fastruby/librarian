require "rails_helper"

RSpec.describe Share do
  describe "#valid?" do
    context "when it does not have a link or the minimum requirements" do
      it "is not valid" do
        link = Share.new
        
        expect(link.valid?).to be_falsey
        expect(link.errors.full_messages).to eq ["Link must exist", "Utm source can't be blank", "Utm campaign can't be blank", "Utm medium can't be blank", "Utm term can't be blank"]
      end
    end
  end
end