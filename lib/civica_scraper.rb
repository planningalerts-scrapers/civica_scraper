require "civica_scraper/version"

require "civica_scraper/authority/burwood"

module CivicaScraper
  AUTHORITIES = {
    burwood: {}
  }

  def self.scrape_and_save(authority)
    if authority == :burwood
      Authority::Burwood.scrape_and_save
    else
      raise "Unknown authority: #{authority}"
    end
  end
end
