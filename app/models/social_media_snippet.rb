class SocialMediaSnippet < ApplicationRecord
  belongs_to :link

  validates :content, presence: true
end
