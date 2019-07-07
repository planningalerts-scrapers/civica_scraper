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
    woollahra: {},
    nambucca: {},
    cairns: {},
    mount_gambier: {},
    norwood: {},
    tea_tree_gully: {},
    loxton_waikerie: {},
    orange: {},
    gawler: {}
  }.freeze

  def self.scrape_and_save(authority)
    if authority == :burwood
      CivicaScraper.scrape_and_save_period2(
        url: "https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=219",
        period: :last7days
      )
    elsif authority == :wollondilly
      CivicaScraper.scrape_and_save_period2(
        url: "https://ecouncil.wollondilly.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=40801",
        period: :last7days
      )
    elsif authority == :woollahra
      Authority::Woollahra.scrape_and_save
    elsif authority == :nambucca
      CivicaScraper.scrape_and_save_period2(
        url:
          "https://eservices.nambucca.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=2811",
        period: :last10days
      )
    elsif authority == :cairns
      CivicaScraper.scrape_and_save_period2(
        url: "https://eservices.cairns.qld.gov.au/eservice/daEnquiryInit.do?nodeNum=227",
        period: :last30days
      )
    elsif authority == :mount_gambier
      CivicaScraper.scrape_and_save_period2(
        url: "https://ecouncil.mountgambier.sa.gov.au/eservice/daEnquiryInit.do?nodeNum=21461",
        period: :last2months
      )
    elsif authority == :norwood
      CivicaScraper.scrape_and_save_period2(
        url: "https://ecouncil.npsp.sa.gov.au/eservice/daEnquiryInit.do?doc_typ=155&nodeNum=10209",
        period: :lastmonth
      )
    elsif authority == :tea_tree_gully
      CivicaScraper.scrape_and_save_period2(
        url: "https://www.ecouncil.teatreegully.sa.gov.au/eservice/daEnquiryInit.do?nodeNum=131612",
        period: :lastmonth
      )
    elsif authority == :loxton_waikerie
      CivicaScraper.scrape_and_save_period2(
        url: "https://eservices.loxtonwaikerie.sa.gov.au/eservice/daEnquiryInit.do?nodeNum=2811",
        period: :lastmonth
      )
    elsif authority == :orange
      CivicaScraper.scrape_and_save_period2(
        url: "https://ecouncil.orange.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=24",
        period: :last30days
      )
    elsif authority == :gawler
      # Has an incomplete SSL chain: See
      # https://www.ssllabs.com/ssltest/analyze.html?d=eservices.gawler.sa.gov.au
      CivicaScraper.scrape_and_save_period2(
        url: "https://eservices.gawler.sa.gov.au/eservice/daEnquiryInit.do?doc_typ=4&nodeNum=3228",
        period: :lastmonth,
        disable_ssl_certificate_check: true
      )
    else
      raise "Unknown authority: #{authority}"
    end
  end

  def self.scrape_and_save_period2(
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

    scrape_and_save_period(
      url,
      date_from,
      Date.today,
      disable_ssl_certificate_check: disable_ssl_certificate_check
    )
  end

  def self.scrape_and_save_period(
    base_url, date_from, date_to, disable_ssl_certificate_check: false
  )
    agent = Mechanize.new
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE if disable_ssl_certificate_check
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
