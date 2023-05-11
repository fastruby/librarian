class Link < ApplicationRecord
  validates :url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  has_many :shares
  has_many :social_media_snippets

  after_create :create_chat_gpt_snippets

  class << self
    def find_urls(sitemap)
      sitemap.to_a.select {|x| x.end_with? ".html" }.reject {|x| x.include?("page") || x.include?("/tags/") || x.include?("author") }
    end

    def find_description(page)
      element = page.at('meta[name="description"]') ||
                page.at('meta[itemprop="description"]') ||
                page.at('meta[name="twitter:description"]')

      element.nil? ? "" : element[:content]
    end

    def find_open_graph_description(page)
      element = page.at('meta[property="og:description"]') ||
                page.at('meta[property="article:section"]')

      element.nil? ? "" : element[:content]
    end

    def find_published_time(page)
      element = page.at('meta[property="article:published_time"]')

      element.nil? ? "" : element[:content]
    end

    def sync!(sitemap)
      find_urls(sitemap).each do |str|
        puts "Url: #{str}"

        link = Link.find_or_create_by(url: str)

        mechanize = Mechanize.new

        page = mechanize.get(str)

        description = find_description(page)
        open_graph_description = find_open_graph_description(page)
        published_time_string = find_published_time(page)
        published_time = if published_time_string.present?
          Time.parse(published_time_string)
        end


        link.update! title: page.title,
                     description: description,
                     open_graph_description: open_graph_description

        if published_time.present?
          link.update! published_at: published_time
        end
      end
    end
  end

  private

  def create_chat_gpt_snippets
    ["Twitter", "LinkedIn"].each do |network|
      fetch_social_media_snippets(social_media_site: network).each do |content|
        self.social_media_snippets.create(content: content, social_media_type: network)
      end
      sleep(2)
    end
  end

  def fetch_social_media_snippets(social_media_site: "Twitter")
    client = OpenAI::Client.new(access_token: ENV["OPEN_AI_ACCESS_TOKEN"])

    response = client.chat(
      parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: gpt_prompt(social_media_site: social_media_site) }],
          temperature: 0.7,
      }
    )
    text = response.dig("choices", 0, "message", "content")
    puts text

    text.split("\n").reject(&:blank?)
  end

  def gpt_prompt(social_media_site: "Twitter")
    "Please generate three social media snippets for #{social_media_site} using this article "\
    "and make sure to include at least one relevant hashtag: #{self.url}. Don't add the url to the social media snippet."
  end
end
