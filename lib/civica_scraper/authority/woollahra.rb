module CivicaScraper
  module Authority
    module Woollahra
      def self.scrape_and_save
        # Doesn't seem to work without that nodeNum. I wonder what it is.
        url = "https://eservices.woollahra.nsw.gov.au/eservice/advertisedDAs.do?&orderBy=suburb&nodeNum=5265"
        # We can't give a link directly to an application. Bummer. So, giving link to the search page
        info_url = "https://eservices.woollahra.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=5270"

        agent = Mechanize.new
        page = agent.get(info_url)

        page = Page::Search.advertised(page)

        Page::Index.scrape(page) do |record|
          # Now scrape the detail page so that we can get the notice information
          page = agent.get(record[:url])
          record_detail = Page::Detail.scrape(page)

          CivicaScraper.save(
            # The address on the detail page for woollahra for some applications
            # (e.g. 166/2019) is messed up. It looks like it's a combination of
            # a couple of addresses. So, using the address from the index page
            # instead
            "address" => record[:address],
            "description" => record_detail[:description],
            "council_reference" => record_detail[:council_reference],
            # We can't give a link directly to an application.
            # Bummer. So, giving link to the search page
            "info_url" => info_url,
            "date_scraped" => Date.today.to_s,
            "date_received" => record_detail[:date_received],
            "on_notice_from" => record_detail[:on_notice_from],
            "on_notice_to" => record_detail[:on_notice_to]
          )
        end
      end
    end
  end
end
