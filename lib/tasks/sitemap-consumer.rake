task :read do
  require "sitemap-parser"
  puts "Reading sitemap..."

  sitemap = SitemapParser.new "http://ombulabs.com.s3.amazonaws.com/sitemap.xml", recurse: true

  sitemap.urls # => Array of Nokigiri XML::Node objects
  sitemap.to_a.select {|x| x.end_with? ".html" }.reject {|x| x.include?("page") || x.include?("/tags/") || x.include?("author") }.each do |str|
    puts "Url: #{str}"
  end

  puts "Read sitemap!"
end