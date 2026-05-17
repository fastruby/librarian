class Share < ApplicationRecord
  belongs_to :link

  UTM_SOURCES = %w[
    Bing
    Bluesky
    ConvertKit
    Facebook
    Google
    LinkedIn
    Lobsters
    Mastodon
    Matz
    NodeWeekly
    Reddit
    RubyWeekly
    Twitter
    Yahoo
  ].sort!

  UTM_MEDIUMS = %w[
    Organic
    PaidPlacement
    PPC
  ].sort!

  UTM_CAMPAIGN = %w[
    Recruitment
    Upgraderuby
    Upgradejs
    Upgradenodejs
    Blogpromo
  ].sort!

  UTM_CONTENT = %w[
    Photo
    Video
    Carousel
    Graphic
    Textonly
    Meme
    Gif
  ].sort!

  validates :utm_source, :utm_campaign, :utm_medium, :utm_term, presence: true
  validates :utm_source,   inclusion: { in: UTM_SOURCES,  allow_blank: true }, on: :create
  validates :utm_medium,   inclusion: { in: UTM_MEDIUMS,  allow_blank: true }, on: :create
  validates :utm_campaign, inclusion: { in: UTM_CAMPAIGN, allow_blank: true }, on: :create
  validates :utm_content,  inclusion: { in: UTM_CONTENT,  allow_blank: true }, on: :create

  def calculated_url
    uri = URI(link.url)

    params = Hash[URI.decode_www_form(uri.query || '')].merge(utm_params)
    uri.query = URI.encode_www_form(params)

    uri.to_s
  end

  def shorten
    rebrandly_client = OmbuLabs::Shortener::RebrandlyClient.new(calculated_url)
    rebrandly_client.shorten
  end

  def utm_params
    {
      "utm_source" => utm_source,
      "utm_medium" => utm_medium,
      "utm_campaign" => utm_campaign,
      "utm_term" => utm_term,
      "utm_content" => utm_content,
      "utm_id" => utm_id
    }
  end
end
