require 'uri'
require 'json'
require 'nokogiri'
require 'open-uri'

class Crawler

  # Things to blacklist and categorize
  Assets = %w(7z aac ac3 aiff ape asf asx asx avi bin css djvu doc docx dtd epub exe f4v flv gif gz ico jar jpg jpeg js m1v m3u mka mkv mov mp2 mp3 mp4 mpeg mpg ogg pdf png pps ppt rar raw rss swf tar wav wma wmv xls xml xsd zip)

  attr_accessor :site_map

  def initialize(url, depth)
    # How many levels deep to crawl
    @depth = depth
    # Just a little counter to keep track of the number of pages hit
    @page_counter = 0
    @site_map = { stats: {}, pages: {} }
    @url = url
  end

  def generate_map(opts = {})
    @site_map[:pages][@url] = false
    increment_crawl
    @site_map[:stats][:pages] = @site_map[:pages].keys.size
    return @site_map
  end

  def write_map(filename)
    # Append json file extension if it is missing
    if filename.split('.').last != 'json'
      filename += '.json'
    end

    json = JSON.pretty_generate @site_map

    File.open(filename, 'w') { |f| f.write json }
  end

  private

  def request_page(url)
    begin
      open(url, read_timeout: 4)
    rescue
      return false
    end
  end

  def clean_link(link)
    link = link.attribute('href').to_s
    # Append missing protocols
    if link =~ /^\/\//
      return URI(@url).scheme + ':' + link
    # Append url to relative paths
    elsif link =~ /^\//
      return @url + link
    end

    return link
  end

  def increment_crawl
    # Keep track of how many levels deep we are
    if @depth > 0
      @depth -= 1

      link_buffer = {}

      @site_map[:pages].each do |key, val|
        next if val
        req = request_page(key)
        unless req
          link_buffer[key] = 'error'
          next
        end
        body = Nokogiri::HTML req
        link_buffer[key] = {}
        link_buffer[key][:title] = body.css('title').text
        # Initialize collection
        links = []
        # Format the retrieved urls
        body.css('a').each do |link|
          links.push clean_link(link)
        end
        body.css('link').each do |link|
          links.push clean_link(link)
        end
        body.css('img').each do |link|
          links.push clean_link(link)
        end

        # Filter out redundant links
        links.uniq!

        # More filtering...
        links = links.select do |link|
          # Filter out invalid links
          if is_invalid(link)
            false
          # Filter out assets
          elsif is_asset(link)
            link_buffer[key][:assets] ||= []
            link_buffer[key][:assets].push(link)
            false
          # Filter out external links
          elsif is_external(link)
            link_buffer[key][:external_links] ||= []
            link_buffer[key][:external_links].push(link)
            false
          else
            # Filter out previously crawled
            @site_map[:pages][link].nil?
          end
        end
        link_buffer[key][:pages] = links.size
        links.each { |link| link_buffer[link] = false }
      end

      @site_map[:pages].merge!(link_buffer)
      increment_crawl
    end
  end

  def is_asset(link)
    Assets.each do |asset|
      return true if link =~ /\.#{asset}$/i
    end
    false
  end

  def is_external(link)
    !link.include? @url
  end

  def is_invalid(link)
    !(link =~ URI::regexp)
  end

end
