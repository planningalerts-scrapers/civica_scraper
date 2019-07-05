module CivicaScraper
  module Authority
    module Nambucca
      def self.scrape_index(page)
        headings = page.at('.bodypanel ~ div').search('h2')
        (0..headings.size - 1).each do |i|
          heading = headings[i]
          d = heading.next_sibling
          date_received = Date.strptime(d.at('span:contains("Date Lodged") ~ span').inner_text, '%d/%m/%Y').to_s rescue nil

          yield(
            council_reference: d.at('span:contains("Application No.") ~ span').inner_text,
            address: heading.inner_text,
            description: d.at('span:contains("Type of Work") ~ span').inner_text,
            date_received: date_received
          )
        end
      end

      def self.scrape_and_save
        date_from = Date.today - 10
        date_to = Date.today

        info_url = 'https://eservices.nambucca.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=2811'

        # Grab the starting page and put in the date and her we go
        agent = Mechanize.new
        page = agent.get(info_url)

        page = Page::Search.period(page, date_from, date_to)

        scrape_index(page) do |record|
          CivicaScraper.save(
            'council_reference' => record[:council_reference],
            'address' => record[:address],
            'description' => record[:description],
            'info_url' => info_url,
            'date_scraped' => Date.today.to_s,
            'date_received' => record[:date_received]
          )
        end
      end
    end
  end
end
