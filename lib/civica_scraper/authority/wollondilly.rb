module CivicaScraper
  module Authority
    module Wollondilly
      def self.has_blank?(record)
        record.values.any?{|v| v.nil? || v.length == 0}
      end

      def self.scrape_index_page(formpage)
        results = formpage.at('div.bodypanel ~ div')

        count = results.search("h4").size - 1
        for i in 0..count
          yield(
            council_reference: (results.search('span[contains("Application No.")] ~ span')[i].text rescue nil),
            address: (results.search('h4')[i].text.gsub('  ', ', ') rescue nil),
            description: (results.search('span[contains("Type of Work")] ~ span')[i].text rescue nil),
            date_received: (Date.strptime(results.search('span[contains("Date Lodged")] ~ span')[i].text, '%d/%m/%Y').to_s rescue nil)
          )
        end
      end

      def self.scrape_and_save
        base_url = "https://ecouncil.wollondilly.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=40801"

        date_from = Date.today - 7
        date_to = Date.today

        agent = Mechanize.new
        datepage = agent.get(base_url)

        formpage = Page::Search.period(datepage, date_from, date_to)

        scrape_index_page(formpage) do |record|
          unless has_blank?(record)
            CivicaScraper.save(
              'council_reference' => record[:council_reference],
              'address' => record[:address],
              'description' => record[:description],
              'info_url' => base_url,
              'date_scraped' => Date.today.to_s,
              'date_received' => record[:date_received]
            )
          else
            puts "Something not right here: #{record}"
          end
        end
      end
    end
  end
end
