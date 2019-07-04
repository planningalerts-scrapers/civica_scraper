# frozen_string_literal: true

require "civica_scraper/authority/burwood"
require "civica_scraper/authority/wollondilly"
require "civica_scraper/authority/woollahra"
require "civica_scraper/page/detail"
require "civica_scraper/page/index"
require "civica_scraper/page/search"
require "civica_scraper/version"

require "scraperwiki"
require "mechanize"

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

  def self.save(record)
    puts "Saving record " + record["council_reference"] + ", " + record["address"]
    ScraperWiki.save_sqlite(["council_reference"], record)
  end
end
