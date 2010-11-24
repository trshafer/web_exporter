require 'net/http'
require 'uri'
require 'open-uri'
require 'hpricot'
require './static_asset'

require './url_utils'

class Page < Struct.new(:url, :doc)

  include UrlUtils

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
  
  def links
    doc.search("body a")
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
  
  def make_internal_links_relative!
    domain = get_domain(url)
    links = doc.search("body a")
    links.each do |link|
      link_url = link['href']
      # must be either absolute link or path to this domain
      next if link_url.index(domain) != 0 and link_url.index('/') != 0
      a = StaticAsset.new(link_url)
      new_path = a.relative_path(url)
      new_path = 'index' if new_path == ''
      link['href'] = "#{new_path}.html"
    end
  end
  
end

# url = 'http://becca.local/mechanism'
# 
# url_object = open(url)
# 
# doc = Hpricot(url_object)
# 
# p = Page.new(url, doc)
# 
# p.make_internal_links_relative
# puts p.links.inspect

#
# puts p.static_assets
