# frozen_string_literal: true

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
      CivicaScraper.scrape_and_save_period(
        # TODO: Get this weird url (with a nodeNum whatever that is) by following
        # a link from a more consistent url
        "https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=219",
        Date.today - 7,
        Date.today
      )
    elsif authority == :wollondilly
      CivicaScraper.scrape_and_save_period(
        "https://ecouncil.wollondilly.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=40801",
        Date.today - 7,
        Date.today
      )
    elsif authority == :woollahra
      Authority::Woollahra.scrape_and_save
    else
      raise "Unknown authority: #{authority}"
    end
  end

  def self.scrape_and_save_period(base_url, date_from, date_to)
    agent = Mechanize.new
    page = agent.get(base_url)
    page = Page::Search.period(page, date_from, date_to)

    Page::Index.scrape(page) do |record|
      CivicaScraper.save(
        "council_reference" => record[:council_reference],
        "address" => record[:address],
        "description" => record[:description],
        # We can't give a link directly to an application.
        # Bummer. So, giving link to the search page
        "info_url" => base_url,
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
