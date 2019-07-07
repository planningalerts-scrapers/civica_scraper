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
    burwood: {
      url: "https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=219",
      period: :last7days
    },
    wollondilly: {
      url: "https://ecouncil.wollondilly.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=40801",
      period: :last7days
    },
    woollahra: {},
    nambucca: {
      url:
        "https://eservices.nambucca.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=2811",
      period: :last10days
    },
    cairns: {
      url: "https://eservices.cairns.qld.gov.au/eservice/daEnquiryInit.do?nodeNum=227",
      period: :last30days
    },
    mount_gambier: {
      url: "https://ecouncil.mountgambier.sa.gov.au/eservice/daEnquiryInit.do?nodeNum=21461",
      period: :last2months
    },
    norwood: {
      url: "https://ecouncil.npsp.sa.gov.au/eservice/daEnquiryInit.do?doc_typ=155&nodeNum=10209",
      period: :lastmonth
    },
    tea_tree_gully: {
      url: "https://www.ecouncil.teatreegully.sa.gov.au/eservice/daEnquiryInit.do?nodeNum=131612",
      period: :lastmonth
    },
    loxton_waikerie: {
      url: "https://eservices.loxtonwaikerie.sa.gov.au/eservice/daEnquiryInit.do?nodeNum=2811",
      period: :lastmonth
    },
    orange: {
      url: "https://ecouncil.orange.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=24",
      period: :last30days
    },
    gawler: {
      url: "https://eservices.gawler.sa.gov.au/eservice/daEnquiryInit.do?doc_typ=4&nodeNum=3228",
      period: :lastmonth,
      # Has an incomplete SSL chain: See
      # https://www.ssllabs.com/ssltest/analyze.html?d=eservices.gawler.sa.gov.au
      disable_ssl_certificate_check: true
    }
  }.freeze

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
