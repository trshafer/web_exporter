require './static_asset'

class CssFixer < Struct.new(:url, :content)
  
  attr_accessor :linked_images
  def fix!
    @linked_images = []
    content.gsub!(/url\((.*)\)/) do |x|
      @linked_images << $1
      "url(#{make_relative($1)})"
    end
    self
  end

  def make_relative(asset_url)
    s = StaticAsset.new(asset_url)
    s.relative_path(url)
  end

end

# content = <<-CSS
# 
# body {
#   font-family: Times New Roman, Times, serif;
# font-size: 19px; }
# 
# #content {
# height: 100%;
# background-image: url(/images/cooltree.png);
# background-repeat: no-repeat;
# overflow: hidden; }
# #content #navigation {
# background-image: url(/images/cooltree2.png);
# 
# float: left; }
# #content #navigation a {
# cursor: hand;
# cursor: pointer; }
# #content #navigation a img {
# cursor: hand;
# cursor: pointer; }
# #content #navigation li.home {
# margin-left: 100px; }
# #content #navigation li.phylogeny {
# margin-top: 88px; }
# #content #navigation li.ontology {
# margin-top: 10px; }
# #content #navigation li.mechanism {
# margin-top: 9px; }
# #content #navigation li.adaptive_value {
# margin-top: 8px; }
# #content #navigation li.references {
# margin-top: 13px; }
# #content #main {
# float: left; }
# #content #main #the-song-of-the-gibbons {
# margin-left: 340px;
# margin-top: 10px; }
# #content #main #main-info {
# margin-top: 17px;
# margin-left: 90px; }
# CSS
# 
# url = 'http://becca.local/stylesheets/application.css'
# c = CssFixer.new(url, content)
# c.fix!
# 
# puts c.linked_images.inspect
# # if url =~ /\.css$/
# #   raise url
# # end
# puts c.content
