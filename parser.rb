require 'mechanize'
require 'pry'
mechanize = Mechanize.new

page = mechanize.get('https://www.zillow.com/homedetails/516-W-Lafayette-St-Easton-PA-18042/10122447_zpid/')
z = {}
page.css('div.hdp-facts.zsg-content-component.z-moreless > div.fact-group-container.zsg-content-component.top-facts').each do |x|
  fact = x.css("h3").text
  facts = []
	x.css("ul").each do |ul|	
	  facts << ul.css("li").children.select(&:text?).collect(&:text).reject(&:empty?)
	  z[fact.to_sym] = facts.flatten
	end
end
z[:description] = page.at('.notranslate.zsg-content-item').text.strip
z[:address] = page.at(".zsg-content-header.addr > h1").text.strip
z[:area] = page.at(".zsg-content-header.addr > h3").text.strip
puts z
#puts page.uri
