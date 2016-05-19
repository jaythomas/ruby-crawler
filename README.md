# ruby-crawler
[![Build Status](https://travis-ci.org/jaythomas/ruby-crawler.svg?branch=master)](https://travis-ci.org/jaythomas/ruby-crawler)

A proof-of-concept site map generator written in roughly 2-3 hours. There isn't much re-invention here as the focus was to write something as simple as possible and structured in a way that is testable.

Although coverage is not thorough, my favorite part was writing some specs and stubbing out the network requests. Rspec is a powerful and simple tool and without it, the code could not have been put together in the short amount of time it was.

## Synopsis
./crawler.rb fetch --depth 8 --url "http://example.com" --output "output.json"

### --depth
Specify the deepest level to crawl from the seed url. Default: 8

### --output
File to output the results to. Defaut: output.json

### --url
Specify the site you wish to crawl.
