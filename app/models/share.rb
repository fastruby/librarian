class Share < ApplicationRecord
  belongs_to :link

  validates :utm_source, :utm_campaign, :utm_medium, :utm_term, presence: true

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

  def calculated_url
    uri = URI(link.url)

    params = Hash[URI.decode_www_form(uri.query || '')].merge(utm_params)
    uri.query = URI.encode_www_form(params)
    
    uri.to_s
  end
end
