class Share < ApplicationRecord
  belongs_to :link

  UTM_SOURCES = %w[
    Facebook
    LinkedIn
    Twitter
    Mastodon
    ConvertKit
    RubyWeekly
    NodeWeekly
    Matz
    Bing
    Google
    Yahoo
    Reddit
    Lobsters
  ]

  UTM_MEDIUMS = %w[
    PPC
    Organic
    PaidPlacement
  ]

  validates :utm_source, :utm_campaign, :utm_medium, :utm_term, presence: true

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
