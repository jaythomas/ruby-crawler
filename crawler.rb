#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'uri'
require 'anemone'
require 'json'
require 'pp'

program :name, 'crawler'
program :version, '0.0.1'
program :description, 'Generate a JSON sitemap with ease.'

def generate_map(url, depth)
  # The sitemap as a hash
  output = {}
  # Just a little counter to keep track of the number of pages hit
  counter = 0

  Anemone.crawl url, depth_limit: depth do |a|
    a.on_every_page do |page|
      # Print some progress dots so the user knows we're doing something
      counter += 1
      print '.' if counter % 32 == 0

      output[page.url] = {
        title: get_page_title(page.body),
        assets: get_page_assets(page.body)
      }
    end
  end

  output
end

def get_page_assets(body)
  return [] if body.nil?
  pattern = /http[s]?:\/\/(.+)\/(.+)\.(gif|jp[e]g|png|js|css)/i
  body.scan pattern
end

def get_page_title(body)
  #res.scan(/<cite>([^<>]*)<\/cite>/imu).flatten
  'Untitled'
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
  c.option '--depth NUMBER', 'How many levels deep to crawl. Default: 6'
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

    options.default :depth => 6
    options.default :output => 'output.json'

    map = generate_map(options.url, options.depth.to_i)
    write_map(options.output, map)

  end

end
