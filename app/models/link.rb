class Link < ApplicationRecord

  class << self
    def find_urls(sitemap)
      sitemap.to_a.select {|x| x.end_with? ".html" }.reject {|x| x.include?("page") || x.include?("/tags/") || x.include?("author") }
    end

    def sync!(sitemap)
      find_urls(sitemap).each do |str|
        puts "Url: #{str}"

        link = Link.find_or_create_by(url: str)

        mechanize = Mechanize.new
        
        page = mechanize.get(str)

        description = page.at('meta[name="description"]')[:content]
        
        link.update! title: page.title, description: description

        puts page.title
      end
    end
  end
  
end
