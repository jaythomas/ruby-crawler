#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'uri'
require 'anemone'
require 'json'

program :name, 'crawler'
program :version, '0.0.1'
program :description, 'Generate a JSON sitemap with ease.'

# Things to blacklist and categorize
Assets = %w(7z aac ac3 aiff ape asf asx asx avi bin css djvu doc docx dtd epub exe f4v flv gif gz ico jar jpg jpeg js m1v m3u mka mkv mov mp2 mp3 mp4 mpeg mpg ogg pdf png pps ppt rar raw rss swf tar wav wma wmv xls xml xsd zip)

def generate_map(url, depth)
  # The sitemap as a hash
  output = { stats: {}, pages: {} }
  # Just a little counter to keep track of the number of pages hit
  counter = 0

  Anemone.crawl url, depth_limit: depth do |a|
    a.skip_links_like(/\.#{Assets.join('|')}$/i)

    a.on_every_page do |page|
      # Print some progress dots so the user knows we're doing something
      counter += 1
      print '.' if counter % 20 == 0

      page_title = get_page_title page.body
      page_assets = get_page_assets page.body

      output[:pages][page.url] = {}
      output[:pages][page.url][:title] = page_title
      output[:pages][page.url][:assets] = page_assets if page_assets.size > 0
    end

    a.after_crawl do |pages|
      output[:stats][:pages] = pages.uniq!.size
      puts "#{pages.uniq!.size} pages processed"
    end
  end

  output
end

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

def write_map(filename, map)
  # Append json file extension if it is missing
  if filename.split('.').last != 'json'
    filename += '.json'
  end

  json = JSON.pretty_generate map

  File.open(filename, 'w') { |f| f.write json }
end

command :fetch do |c|
  c.syntax = 'crawler fetch --depth [depth] --url [url] --file [file]'
  c.summary = 'Crawl a site and output the site directory to a file.'
  c.example 'Only a url is required.', 'crawler fetch --url "http://r.gfax.ch" --depth 4 --output "output.json"'
  c.option '--depth NUMBER', 'How many levels deep to crawl. Default: 8'
  c.option '--url STRING', String, 'Site you wish to crawl.'
  c.option '--output STRING', String, 'File to output the results to. Default: output.json'
  c.action do |args, options|

    if options.url.nil?
      say 'Please specify the url you wish to crawl from.'
      next
    end

    unless options.url =~ URI.regexp
      say 'Please provide a valid url.'
      next
    end

    options.default :depth => 8
    options.default :output => 'output.json'

    map = generate_map(options.url, options.depth.to_i)
    write_map(options.output, map)

  end

end
