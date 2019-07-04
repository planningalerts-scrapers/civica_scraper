module CivicaScraper
  module Authority
    module Burwood
      def self.scrape_and_save
        date_from = Date.today - 7
        date_to = Date.today

        general_search_url = 'https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=219'

        # Grab the starting page and go into each link to get a more reliable data format.
        agent = Mechanize.new
        page = agent.get(general_search_url)

        page = Page::Search.period(page, date_from, date_to)

        Page::Index.scrape(page) do |record|
          # Just use the url for the time being
          doc = agent.get(record[:url])
          record = Page::Detail.scrape(doc)
          CivicaScraper.save(
            'council_reference' => record[:council_reference],
            'address' => record[:address],
            'description' => record[:description],
            'info_url' => general_search_url,
            'date_received' => record[:date_received],
            'date_scraped' => Date.today.to_s
          )
        end
      end
    end
  end
end
