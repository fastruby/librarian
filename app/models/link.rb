class Link < ApplicationRecord
  validates :url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  has_many :shares

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

end
