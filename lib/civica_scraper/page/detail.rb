# frozen_string_literal: true

module CivicaScraper
  module Page
    # A page with all the information (hopefully) about a single
    # development application
    module Detail
      def self.scrape(doc)
        rows = doc.search(".rowDataOnly > .inputField:nth-child(2)").map { |e| e.inner_text.strip }
        {
          council_reference: rows[2],
          address: rows[0],
          description: rows[1],
          date_received: Date.strptime(rows[3], "%d/%m/%Y").to_s
        }
      end
    end
  end
end
