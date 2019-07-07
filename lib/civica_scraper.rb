# frozen_string_literal: true

require "civica_scraper/authority/woollahra"
require "civica_scraper/page/detail"
require "civica_scraper/page/index"
require "civica_scraper/page/search"
require "civica_scraper/authorities"
require "civica_scraper/version"

require "scraperwiki"
require "mechanize"

# Scrape civica websites
module CivicaScraper
  def self.scrape_and_save(authority)
    if authority == :woollahra
      Authority::Woollahra.scrape_and_save
    elsif AUTHORITIES.key?(authority)
      scrape_and_save_period(AUTHORITIES[authority])
    else
      raise "Unknown authority: #{authority}"
    end
  end

  def self.scrape_and_save_period(
    url:, period:, disable_ssl_certificate_check: false
  )
    date_from = if period == :lastmonth
                  Date.today << 1
                elsif period == :last2months
                  Date.today << 2
                elsif period == :last7days
                  Date.today - 7
                elsif period == :last10days
                  Date.today - 10
                elsif period == :last30days
                  Date.today - 30
                else
                  raise "Unexpected period: #{period}"
                end
    date_to = Date.today

    agent = Mechanize.new
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE if disable_ssl_certificate_check
    page = agent.get(url)
    page = Page::Search.period(page, date_from, date_to)

    Page::Index.scrape(page) do |record|
      save(
        "council_reference" => record[:council_reference],
        "address" => record[:address],
        "description" => record[:description],
        # We can't give a link directly to an application.
        # Bummer. So, giving link to the search page
        "info_url" => url,
        "date_received" => record[:date_received],
        "date_scraped" => Date.today.to_s
      )
    end
  end

  def self.save(record)
    puts "Saving record " + record["council_reference"] + ", " + record["address"]
    ScraperWiki.save_sqlite(["council_reference"], record)
  end
end
