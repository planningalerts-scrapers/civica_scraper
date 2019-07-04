module CivicaScraper
  module Authority
    module Wollondilly
      def self.scrape_and_save
        base_url = "https://ecouncil.wollondilly.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=40801"
        date_from = Date.today - 7
        date_to = Date.today

        agent = Mechanize.new
        page = agent.get(base_url)
        page = Page::Search.period(page, date_from, date_to)

        Page::Index.scrape(page) do |record|
          CivicaScraper.save(
            'council_reference' => record[:council_reference],
            'address' => record[:address],
            'description' => record[:description],
            'info_url' => base_url,
            'date_scraped' => Date.today.to_s,
            'date_received' => record[:date_received]
          )
        end
      end
    end
  end
end
