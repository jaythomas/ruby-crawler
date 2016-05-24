#!/usr/bin/env ruby

require 'commander/import'
require './lib/crawler.rb'

program :name, 'crawler'
program :version, '0.0.1'
program :description, 'Generate a JSON site map with ease.'

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

    crawler = Crawler.new(options.url, options.depth.to_i)
    crawler.generate_map(progress: true)
    crawler.write_map(options.output)

  end

end
