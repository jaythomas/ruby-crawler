require 'uri'
require 'anemone'
require 'json'

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

    Anemone.crawl @url, depth_limit: @depth do |a|
      a.skip_links_like(/\.#{Assets.join('|')}$/i)

      a.on_every_page do |page|
        @page_counter += 1
        # Print some progress dots so the user knows we're doing something
        if opts[:progress] == true
          if @page_counter % 20 == 0
            print '.'
          end
        end

        page_title = self.get_page_title page.body
        page_assets = self.get_page_assets page.body

        # Fill in the site map
        @site_map[:pages][page.url.to_s] = {}
        @site_map[:pages][page.url.to_s][:title] = page_title
        @site_map[:pages][page.url.to_s][:assets] = page_assets if page_assets.size > 0
      end

      a.after_crawl do |pages|
        @site_map[:stats][:pages] = pages.uniq!.size
        if opts[:progress] == true
          puts "#{pages.uniq!.size} pages processed"
        end
      end
    end

    @site_map
  end

  def write_map(filename)
    # Append json file extension if it is missing
    if filename.split('.').last != 'json'
      filename += '.json'
    end

    json = JSON.pretty_generate @site_map

    File.open(filename, 'w') { |f| f.write json }
  end

  #private

  def get_page_assets(body)
    return [] if body.nil? or body.empty?

    # Grab all urls in the body
    urls = URI.extract(body, ['http', 'https'])
    # Filter down to just the ones with file extensions
    urls.select! do |url|
      Assets.include? url.split('.').last
    end

    # Don't return duplicates
    return urls.uniq
  end

  def get_page_title(body)
    # This will change the encoding and remove weird characters
    body = body.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
    title_tags = body.scan(/<title>([^<>]*)<\/title>/im).flatten
    title_tags.first || 'Untitled'
  end

end
