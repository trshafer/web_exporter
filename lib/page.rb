require 'net/http'
require 'uri'
require 'open-uri'
require 'hpricot'

class Page < Struct.new(:url, :doc)


  def asset_attribute
    {
      'link' => 'href',
      'script' => 'src',
      'img' => 'src'
    }
  end

  def static_assets

    assets = ["head link[@rel='stylesheet'][@href]", "head script[@type='text/javascript'][@src]", "body img[@src]"]
    asset_paths = []
    assets.each do |css_selector|
      elements = doc.search(css_selector)
      elements.each do |asset|
        attribute = asset_attribute[asset.name]
        asset_paths << asset.attributes[attribute]
      end
    end
    return asset_paths
  end

end

# url = 'http://becca.local'
# 
# url_object = open(url)
# 
# doc = Hpricot(url_object)
# 
# p = Page.new(url, doc)
# 
# puts p.static_assets
