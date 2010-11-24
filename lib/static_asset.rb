class StaticAsset

  attr_accessor :url
  def initialize(url)
    @url = remove_domain(url)
    if this_match = @url.match(/^\/(.*)$/)
      @url = this_match[1]
    end
    @url.gsub!(/\?.*/, '') #Remove all trailing numbers that rails includes
  end


  def self.remove_domain(potential_base, base_slash=true)
    index_to_start_slash_search = potential_base.index('://')
    return potential_base if index_to_start_slash_search == nil
    index_of_first_relevant_slash = potential_base.index('/', index_to_start_slash_search+3) || potential_base.length
    return potential_base[index_of_first_relevant_slash + (base_slash ? 0 : 1), potential_base.length]
  end
  def remove_domain(potential_base)
    StaticAsset.remove_domain(potential_base)
  end


  def relative_path(source_url)
    relative_path_of_source = remove_domain(source_url)
    distance = relative_path_of_source.gsub(/[^\/]/, '').size - 1
    '../' * distance + url
  end
  
  def name
    return @name if defined?(@name)
    if match_data = url.match(/.*\/(.+\..+)/) #just get the last actual name
      @name = match_data[1]
    else
      @name = url
    end
  end
end

# assets = ['javascripts/hello.js', '/javascripts/inner/hello1.js', 'http://google.com/javascripts/hello2.js', 'http://www.google.com/javascripts/hello3.js']
# assets.each do |asset|
#   a = StaticAsset.new(asset)
#   puts a.relative_path
#   puts a.name
# end
