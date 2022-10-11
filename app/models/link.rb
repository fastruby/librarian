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

    def sync!(sitemap)
      find_urls(sitemap).each do |str|
        puts "Url: #{str}"

        link = Link.find_or_create_by(url: str)

        mechanize = Mechanize.new
        
        page = mechanize.get(str)

        description = find_description(page)
        
        link.update! title: page.title, description: description
      end
    end
  end
  
end
