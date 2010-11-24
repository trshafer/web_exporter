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
  
  def path
    this_path = StaticAsset.remove_domain(url, false)
    this_path = 'index' if this_path == ''
    "#{this_path}.html"
  end
  
  def html
    doc.html
  end

  def asset_selectors
    ["head link[@rel='stylesheet'][@href]", "head script[@type='text/javascript'][@src]", "body img[@src]"]
  end

  def stylesheets
    doc.search(asset_selectors[0])
  end

  def javascripts
    doc.search(asset_selectors[1])
  end

  def images
    doc.search(asset_selectors[2])
  end

  # Makes all asset accessors relative, and returns the absolute paths of these assets
  def make_assets_relative!
    asset_paths = []
    asset_selectors.each do |css_selector|
      elements = doc.search(css_selector)
      elements.each do |asset|
        attribute = asset_attribute[asset.name]
        a = StaticAsset.new(asset[attribute])
        asset_paths << a.url
        asset[attribute] = a.relative_path(url)
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
