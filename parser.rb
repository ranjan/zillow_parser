require 'mechanize'
require 'json'
require 'pry'

class ZilloParser
  ZilloUrl = 'https://www.zillow.com'.freeze
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
    puts "Searching For Property in #{address}"
    mechanize = Mechanize.new
    page = mechanize.get(ZilloUrl)
    search_page = page.form_with(id: 'formSearchBar') do |form|
      search_field = form.field_with(id: 'citystatezip')
      search_field.value = address
    end.submit
    parse_property_list(search_page)
  end

  def self.parse_property_list(page)
    puts "Search Page Details: #{page.title} #{page.uri}"
    rs = []
    page.css('div.zsg-photo-card-content.zsg-aspect-ratio-content').each do |p|
      attrs = {}
      attrs[:url] = ZilloUrl + p.css('a').first.attributes['href'].text
      p.css('div.zsg-photo-card-caption').each do |pd|
        attrs[:type] = pd.at('h4.zsg-photo-card-spec > .zsg-photo-card-status').text
        attrs[:value] = pd.css('p.zsg-photo-card-spec > .zsg-photo-card-price').text
        attrs[:address] = pd.at('p.zsg-photo-card-spec > .zsg-photo-card-address').text
      end
      rs << attrs
    end
    puts "\n\t\t\t\tListing Top #{rs.size} properties\n"
    puts JSON.pretty_generate(rs)
    puts "\n\t\t\t\tProperty Details: #{rs.first[:address]}\n"
    parse_home_details(rs.first[:url])
  end
end
address = 'Easton, PA 18042'
puts ZilloParser.get_property_list(address)
