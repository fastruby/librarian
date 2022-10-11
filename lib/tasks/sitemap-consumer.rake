task read: :environment do
  require "sitemap-parser"
  puts "Reading sitemaps..."

  # http://fastruby.io.s3.amazonaws.com/sitemap.xml
  ["ombulabs.com", "fastruby.io"].each do |bucket|
    sitemap = SitemapParser.new "http://#{bucket}.s3.amazonaws.com/sitemap.xml", recurse: true
    Link.sync!(sitemap)
  end

  puts "Read sitemaps!"
end