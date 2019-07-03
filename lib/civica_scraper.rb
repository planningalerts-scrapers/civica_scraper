require "civica_scraper/version"

require "civica_scraper/authority/burwood"
require "civica_scraper/authority/wollondilly"

module CivicaScraper
  AUTHORITIES = {
    burwood: {},
    wollondilly: {}
  }

  def self.scrape_and_save(authority)
    if authority == :burwood
      Authority::Burwood.scrape_and_save
    elsif authority == :wollondilly
      Authority::Wollondilly.scrape_and_save
    else
      raise "Unknown authority: #{authority}"
    end
  end
end
