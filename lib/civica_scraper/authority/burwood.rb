module CivicaScraper
  module Authority
    module Burwood
      def self.scrape_detail_page(doc, info_url)
        rows = doc.search('.rowDataOnly > .inputField:nth-child(2)').map { |e| e.inner_text.strip }
        reference = rows[2]
        date_received = Date.strptime(rows[3], '%d/%m/%Y').to_s rescue nil
        puts "Invalid date: #{rows[3].inspect}" unless date_received

        {
          council_reference: reference,
          address: rows[0],
          description: rows[1],
          info_url: info_url,
          date_received: date_received
        }
      end

      # For the being just returns the urls of the detail pages
      def self.scrape_index_page(page)
        (0..page.search('.non_table_headers').size - 1).each do |i|
          yield(
            url: (page.uri + "daEnquiryDetails.do?index=#{i}").to_s
          )
        end
      end

      def self.scrape_and_save
        date_from = Date.today - 7
        date_to = Date.today

        general_search_url = 'https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=219'

        # Grab the starting page and go into each link to get a more reliable data format.
        agent = Mechanize.new
        page = agent.get(general_search_url)

        page = Page::Search.period(page, date_from, date_to)

        scrape_index_page(page) do |record|
          # Just use the url for the time being
          doc = agent.get(record[:url])
          record = scrape_detail_page(doc, general_search_url)
          CivicaScraper.save(
            'council_reference' => record[:council_reference],
            'address' => record[:address],
            'description' => record[:description],
            'info_url' => record[:info_url],
            'date_received' => record[:date_received],
            'date_scraped' => Date.today.to_s
          )
        end
      end
    end
  end
end
