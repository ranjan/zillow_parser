require 'mechanize'
require 'json'
require 'pry'

class ZilloParser

	def self.parse_home_details(url)
		mechanize = Mechanize.new
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
	end

	def self.get_property_list(address)
		url = 'https://www.zillow.com/'
		mechanize = Mechanize.new
		page = mechanize.get(url)
    search_page = page.form_with(:id => 'formSearchBar') do |form|
    	search_field = form.field_with(:id => 'citystatezip')
    	search_field.value = address
		end.submit
		puts search_page.uri
		puts search_page.title
		parse_property_list(search_page)
	end	

	def self.parse_property_list(page)
		rs = []
		
	  page.css('div.zsg-photo-card-content.zsg-aspect-ratio-content').each do |pg|
      attrs = {}
      #puts pg.at('a').attributes.first.last.value
      attrs[:url] = pg.css('a').first.attributes['href'].text
      
      pg.css('div.zsg-photo-card-caption').each do |x|
        attrs[:type] = x.at('.zsg-photo-card-status').text
      end
      rs << attrs
    end
 
    #puts JSON.pretty_generate(rs)
    #parse_home_details(url) 
	end	
end
address = 'Easton, PA 18042'
puts ZilloParser.get_property_list(address)
