require 'spec_helper'
require 'crawler'
require 'uri'

describe Crawler do
  before(:each) do
    @url = 'http://example.com/'
    @depth = 6

    html_body = <<-HTMLBODY
      <html>

      <head>
        <title>Example Page Title</title>
        <link href="http://cdn.example.com/master.css" rel="stylesheet" />
      </head>

      <body>
        <img href="http://example.com/assets/test_img.jpg">
        <div id="links1">
          <ul>
            <li><a href="//example.com"> Home</a></li>
            <li><a href="NOT A LINK"> Zipper</a></li>
          </ul>
        </div>
        <div id="links2">
          <p>(13-12) <a href="http://example.com/cupcakes.pdf">Cupcake Recipe></a></p>
          <p>(14-12) <a href="http://example.com/brownies.pdf">Brownie Recipe</a></p>
        </div>
      </body>

      </html>
    HTMLBODY

    stub_request(:get, @url).
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Anemone/0.7.2'}).
      to_return(:status => 200, :body => html_body, :headers => {})

    @crawler = Crawler.new(@url, @depth)
  end

  it 'should output pages to a map' do
    map = @crawler.generate_map
    expect(map[:pages].keys.length).to eq(1)
    expect(map[:pages].keys.first).to eq(@url)
  end

  it 'should output page titles to a map' do
    map = @crawler.generate_map
    expect(map[:pages][@url][:title]).to eq('Example Page Title')
  end

  it 'should output page assets to a map' do
    map = @crawler.generate_map
    expect(map[:pages][@url][:assets].length).to eq(4)
  end

  it 'should output stats to a map' do
    map = @crawler.generate_map
    expect(map[:stats][:pages]).to eq(1)
  end
end
