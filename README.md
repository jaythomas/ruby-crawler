# ruby-crawler
[![Build Status](https://travis-ci.org/jaythomas/ruby-crawler.svg?branch=master)](https://travis-ci.org/jaythomas/ruby-crawler)

A proof-of-concept site map generator.

## Synopsis
./crawler.rb fetch --depth 8 --url "http://example.com" --output "output.json"

### --depth
Specify the deepest level to crawl from the seed url. Default: 8

### --output
File to output the results to. Defaut: output.json

### --url
Specify the site you wish to crawl.
