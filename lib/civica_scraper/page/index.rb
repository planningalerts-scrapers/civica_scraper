# frozen_string_literal: true

module CivicaScraper
  module Page
    # Page with list of development applications
    module Index
      def self.scrape(page)
        results = page.at("div.bodypanel ~ div")

        results.search("h4").each do |address|
          d = address.next_sibling

          council_reference = d.at("span[contains('Application No.')] ~ span").text
          description = d.at("span[contains('Type of Work')] ~ span").text
          date_received = d.at("span[contains('Date Lodged')] ~ span").text

          yield(
            council_reference: council_reference,
            address: address.text,
            description: description,
            date_received: Date.strptime(date_received, "%d/%m/%Y").to_s,
            url: (page.uri + address.at("a")["href"]).to_s
          )
        end
      end
    end
  end
end
