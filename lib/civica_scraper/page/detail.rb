# frozen_string_literal: true

module CivicaScraper
  module Page
    # A page with all the information (hopefully) about a single
    # development application
    module Detail
      def self.parse_date(string)
        Date.strptime(string, "%d/%m/%Y")
      rescue ArgumentError
        puts "Invalid date: #{string}"
        nil
      end

      def self.scrape(doc)
        rows = doc.search(".rowDataOnly > .inputField:nth-child(2)").map { |e| e.inner_text.strip }
        {
          council_reference: rows[2],
          address: rows[0],
          description: rows[1],
          date_received: parse_date(rows[3])&.to_s
        }
      end
    end
  end
end
