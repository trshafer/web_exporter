class StaticAsset

  attr_accessor :url
  def initialize(url)
    @url = remove_domain(url)
    if this_match = @url.match(/^\/(.*)$/)
      @url = this_match[1]
    end
  end

  def remove_domain(potential_base)
    index_to_start_slash_search = potential_base.index('://')
    return potential_base if index_to_start_slash_search == nil
    index_of_first_relevant_slash = potential_base.index('/', index_to_start_slash_search+3)
    return potential_base[index_of_first_relevant_slash, potential_base.length]
  end


  def relative_path(distance=0)
    '../' * distance + url
  end
  
  def name
    return @name if defined?(@name)
    if match_data = url.match(/.*\/(.+\..+)/)
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
