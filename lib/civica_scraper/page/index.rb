# frozen_string_literal: true

module CivicaScraper
  module Page
    # Page with list of development applications
    module Index
      def self.scrape(page)
        results = page.at("div.bodypanel ~ div")
        count = results.search("h4").size - 1

        dates_received = results.search("span[contains('Date Lodged')] ~ span")
        council_references = results.search("span[contains('Application No.')] ~ span")
        addresses = results.search("h4")
        descriptions = results.search("span[contains('Type of Work')] ~ span")

        (0..count).each do |i|
          yield(
            council_reference: council_references[i].text,
            address: addresses[i].text,
            description: descriptions[i].text,
            date_received: Date.strptime(dates_received[i].text, "%d/%m/%Y").to_s,
            url: (page.uri + "daEnquiryDetails.do?index=#{i}").to_s
          )
        end
      end
    end
  end
end
