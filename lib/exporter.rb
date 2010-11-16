require 'rubygems'
require './spider'


spider = Spider.new('http://becca.local')
spider.crawl!

spider.locate_static_assets!

spider.visited_pages.each do |url, page|
  puts page.inspect
end