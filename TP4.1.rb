require 'net/http'
require 'uri'

def open(url)
  Net::HTTP.get(URI.parse(url))
end

page_content = open('http://bandcamp.com/')
puts page_content

