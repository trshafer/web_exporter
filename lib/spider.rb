require 'net/http'
require 'uri'
require 'open-uri'
require 'hpricot'
require './url_utils'
require './page'
require './static_asset'
require './css_fixer'


class Spider
  include UrlUtils

  attr_accessor :visited_pages, :domain, :static_assets
  def initialize(domain)
    @domain = clean_root_domain(domain)
    @visited_pages = {}
    @css_images = []
  end

  def crawl!
    crawl_domain(@domain)
  end

  def format_pages!
    # Page is an Object with url => url, doc => Hpricot Object
    all_static_assets = []
    @visited_pages.each_pair do |url, page|
      page.make_internal_links_relative!
      page_static_assets = page.make_assets_relative!
      all_static_assets += page_static_assets
    end
    @static_assets = all_static_assets.uniq
  end

  def store_the_internet!(path='/Users/2collegebums/Apps/web_exporter/tmp/')
    @visited_pages.each_pair do |url, page|
      force_write("#{path}#{page.path}", page.html)
    end
    save_assets(@static_assets, path)
    save_assets(@css_images, path)
  end

  def save_assets(assets, path)
    assets.each do |url|
      url_document = open_url("#{@domain}#{url}")
      if url_document
        document = parse_url(url_document)
        html = cleanup_static_asset("#{@domain}#{url}", document.html)
        force_write("#{path}#{url}", html)
      end
    end
  end

  def cleanup_static_asset(full_url, html)
    if full_url =~  /\.css\d*$/
      css_fixer = CssFixer.new(full_url, html)
      css_fixer.fix!
      html = css_fixer.content
      @css_images += css_fixer.linked_images
      puts html
    end
    html
  end


  def force_write(file_location, content=nil)
    directory = File.dirname(file_location) + "/"
    ensure_directory!(directory)
    File.open(file_location, 'w+') do |f|
      f.write(content)
    end
  end

  def ensure_directory!(directory)
    first_index = 0
    checking_directory = '/'
    while checking_directory != directory
      first_index = directory.index('/', first_index)
      second_index = directory.index('/', first_index+1)
      checking_directory = directory[0..second_index]
      Dir.mkdir(checking_directory) unless Dir.exists?(checking_directory)
      first_index = second_index
    end
  end

  def crawl_domain(url, page_limit = 100)
    return if @visited_pages.size == page_limit
    url_object = open_url(url)
    return if url_object == nil
    parsed_url = parse_url(url_object)
    return if parsed_url == nil
    @visited_pages[url] ||= Page.new(url, parsed_url)
    page_urls = find_urls_on_page(parsed_url, url)
    page_urls.each do |page_url|
      if @visited_pages[page_url] == nil && urls_on_same_domain?(url, page_url)
        crawl_domain(page_url)
      end
    end
  end

  def open_url(url)
    url_object = nil
    begin
      url_object = open(url)
    rescue
      puts "Unable to open url: " + url
    end
    return url_object
  end

  def update_url_if_redirected(url, url_object)
    if url != url_object.base_uri.to_s
      return url_object.base_uri.to_s
    end
    return url
  end

  def parse_url(url_object)
    doc = nil
    begin
      doc = Hpricot(url_object)
    rescue
      puts 'Could not parse url: ' + url_object.base_uri.to_s
    end
    puts 'Crawling url ' + url_object.base_uri.to_s
    return doc
  end

  def find_urls_on_page(parsed_url, current_url)
    urls_list = []
    parsed_url.search('a[@href]').map do |x|
      new_url = x['href'].split('#')[0]
      unless new_url == nil
        if relative?(new_url)
          new_url = make_absolute(current_url, new_url)
        end
        urls_list.push(new_url)
      end
    end
    return urls_list
  end

  private :open_url, :update_url_if_redirected, :parse_url, :find_urls_on_page
end
