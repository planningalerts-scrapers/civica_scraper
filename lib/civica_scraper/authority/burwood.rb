module CivicaScraper
  module Authority
    module Burwood
      def self.scrape_and_save
        date_from = Date.today - 7
        date_to = Date.today

        # TODO: Get this weird url (with a nodeNum whatever that is) by following
        # a link from a more consistent url
        general_search_url = 'https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=219'

        # Grab the starting page and go into each link to get a more reliable data format.
        agent = Mechanize.new
        page = agent.get(general_search_url)

        page = Page::Search.period(page, date_from, date_to)

        Page::Index.scrape(page) do |record|
          CivicaScraper.save(
            'council_reference' => record[:council_reference],
            'address' => record[:address],
            'description' => record[:description],
            # We can't give a link directly to an application. Bummer. So, giving link to the search page
            'info_url' => general_search_url,
            'date_received' => record[:date_received],
            'date_scraped' => Date.today.to_s
          )
        end
      end
    end
  end
end
