# frozen_string_literal: true

module CivicaScraper
  module Page
    # Page with list of development applications
    module Index
      def self.scrape(page)
        results = page.at("div.bodypanel ~ div")

        results.search("h4").each do |address|
          fields = extract_fields(address.next_sibling)

          yield(
            council_reference: fields[:council_reference],
            address: address.text,
            description: fields[:description],
            date_received: Date.strptime(fields[:date_received], "%d/%m/%Y").to_s,
            url: (page.uri + address.at("a")["href"]).to_s
          )
        end
      end

      def self.extract_fields(div)
        {
          council_reference: div.at("span[contains('Application No.')] ~ span").text,
          description: div.at("span[contains('Type of Work')] ~ span").text,
          date_received: div.at("span[contains('Date Lodged')] ~ span").text
        }
      end
    end
  end
end
