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
    end
  end
end
