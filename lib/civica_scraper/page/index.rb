# frozen_string_literal: true

module CivicaScraper
  module Page
    # Page with list of development applications
    module Index
      # For the being just returns the urls of the detail pages
      def self.scrape(page)
        (0..page.search(".non_table_headers").size - 1).each do |i|
          yield(
            url: (page.uri + "daEnquiryDetails.do?index=#{i}").to_s
          )
        end
      end

      # A slightly different version of this page
      def self.scrape_v2(formpage)
        results = formpage.at("div.bodypanel ~ div")

        count = results.search("h4").size - 1
        (0..count).each do |i|
          yield(
            council_reference: (results.search("span[contains('Application No.')] ~ span")[i].text rescue nil),
            address: (results.search("h4")[i].text.gsub("  ", ", ") rescue nil),
            description: (results.search("span[contains('Type of Work')] ~ span")[i].text rescue nil),
            date_received: (Date.strptime(results.search("span[contains('Date Lodged')] ~ span")[i].text, "%d/%m/%Y").to_s rescue nil)
          )
        end
      end
    end
  end
end
