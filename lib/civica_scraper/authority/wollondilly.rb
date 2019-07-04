module CivicaScraper
  module Authority
    module Wollondilly
      def self.scrape_and_save
        base_url = "https://ecouncil.wollondilly.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=40801"

        date_from = Date.today - 7
        date_to = Date.today

        agent = Mechanize.new
        datepage = agent.get(base_url)

        formpage = Page::Search.period(datepage, date_from, date_to)

        Page::Index.scrape(formpage) do |record|
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
