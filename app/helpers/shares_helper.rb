module SharesHelper
  def utm_source_options
    Share::UTM_SOURCES
  end

  def utm_medium_options
    Share::UTM_MEDIUMS
  end

  def utm_campaign_options
    Share::UTM_CAMPAIGN
  end

  def utm_content_options
    Share::UTM_CONTENT
  end
end
