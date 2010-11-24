require 'rubygems'
require './spider'


spider = Spider.new('http://becca.local')
spider.crawl!
spider.format_pages!
spider.store_the_internet!

# puts spider.static_assets.inspect

# spider.visited_pages.each do |url, page|
#   puts page.inspect
# end