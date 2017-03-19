require 'mechanize'
require 'json'
require 'pry'
mechanize = Mechanize.new

url = ARGV[0] || 'https://www.zillow.com/homedetails/516-W-Lafayette-St-Easton-PA-18042/10122447_zpid/'
page = mechanize.get(url)
result = {}
result[:address] = page.at('.zsg-content-header.addr > h1').text.strip
result[:area] = page.at('.zsg-content-header.addr > h3').text.strip
result[:description] = page.at('.notranslate.zsg-content-item').text.strip
page.css('div.hdp-facts.zsg-content-component.z-moreless > div.fact-group-container.zsg-content-component.top-facts').each do |x|
  fact = x.css('h3').text
  facts = []
  x.css('ul').each do |ul|
    facts << ul.css('li').children.select(&:text?).collect(&:text).reject(&:empty?)
  end
  result[fact.to_sym] = facts.flatten
end

page.css('.zest-content').each do |zc|
  t = zc.at('.zest-title').children.first.text.strip
  result[t] = {}
  result[t][:value] = zc.at('.zest-value').text
  result[t][:low_range] = zc.css('.zest-range-bar-low').text
  result[t][:high_range] = zc.css('.zest-range-bar-high').text
end

puts JSON.pretty_generate(result)
