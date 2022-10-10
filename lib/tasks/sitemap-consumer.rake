task read: :environment do
  require "sitemap-parser"
  puts "Reading sitemap..."

  sitemap = SitemapParser.new "http://ombulabs.com.s3.amazonaws.com/sitemap.xml", recurse: true

  Link.sync!(sitemap)

  puts "Read sitemap!"
end