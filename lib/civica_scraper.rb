# frozen_string_literal: true

require "civica_scraper/version"

require "civica_scraper/authority/burwood"
require "civica_scraper/authority/wollondilly"
require "civica_scraper/authority/woollahra"

# Scrape civica websites
module CivicaScraper
  AUTHORITIES = {
    burwood: {},
    wollondilly: {},
    woollahra: {}
  }.freeze

  def self.scrape_and_save(authority)
    if authority == :burwood
      Authority::Burwood.scrape_and_save
    elsif authority == :wollondilly
      Authority::Wollondilly.scrape_and_save
    elsif authority == :woollahra
      Authority::Woollahra.scrape_and_save
    else
      raise "Unknown authority: #{authority}"
    end
  end
end
