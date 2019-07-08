# frozen_string_literal: true

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
    scrape(authority) do |record|
      save(record)
    end
  end

  def self.scrape(authority)
    raise "Unknown authority: #{authority}" unless AUTHORITIES.key?(authority)

    scrape_period(AUTHORITIES[authority]) do |record|
      yield(record)
    end
  end

  def self.scrape_period(
    url:, period:, disable_ssl_certificate_check: false,
    notice_period: false
  )
    agent = Mechanize.new
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE if disable_ssl_certificate_check
    page = agent.get(url)

    if period == :advertised
      page = Page::Search.advertised(page)
    else
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
      page = Page::Search.period(page, date_from, date_to)
    end

    Page::Index.scrape(page) do |record|
      merged = {
        "council_reference" => record[:council_reference],
        # The address on the detail page for woollahra for some applications
        # (e.g. 166/2019) is messed up. It looks like it's a combination of
        # a couple of addresses. So, using the address from the index page
        # instead
        "address" => record[:address],
        "description" => record[:description],
        # We can't give a link directly to an application.
        # Bummer. So, giving link to the search page
        "info_url" => url,
        "date_received" => record[:date_received],
        "date_scraped" => Date.today.to_s
      }

      if notice_period
        # Now scrape the detail page so that we can get the notice information
        page = agent.get(record[:url])
        record_detail = Page::Detail.scrape(page)

        merged = merged.merge(
          "on_notice_from" => record_detail[:on_notice_from],
          "on_notice_to" => record_detail[:on_notice_to]
        )
      end

      yield(merged)
    end
  end

  def self.log(record)
    puts "Saving record " + record["council_reference"] + ", " + record["address"]
  end

  def self.save(record)
    log(record)
    ScraperWiki.save_sqlite(["council_reference"], record)
  end
end
