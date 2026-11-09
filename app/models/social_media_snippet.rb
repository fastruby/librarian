class SocialMediaSnippet < ApplicationRecord
  SOCIAL_MEDIA_TYPES = %w[
    Bluesky
    GoogleBusiness
    LinkedIn
    Mastodon
    Twitter
  ].sort!

  belongs_to :link
  belongs_to :share, optional: true

  validates :content, presence: true
  # on: :create so snippets saved before this list existed stay editable.
  validates :social_media_type, presence: true, on: :create
  validates :social_media_type, inclusion: { in: SOCIAL_MEDIA_TYPES, allow_blank: true }, on: :create
  validates :content, uniqueness: { scope: %i[link_id social_media_type],
                                    message: "has already been saved for this link and social media type",
                                    allow_blank: true }, on: :create
  validate :share_belongs_to_link

  private

  def share_belongs_to_link
    return if share_id.blank?

    if share.nil?
      errors.add(:share, "must exist")
    elsif share.link_id != link_id
      errors.add(:share, "must belong to the same link")
    end
  end
end
