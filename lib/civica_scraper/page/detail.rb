# frozen_string_literal: true

module CivicaScraper
  module Page
    # A page with all the information (hopefully) about a single
    # development application
    module Detail
      def self.scrape(doc)
        rows = doc.search(".rowDataOnly > .inputField:nth-child(2)").map { |e| e.inner_text.strip }
        reference = rows[2]
        begin
          date_received = Date.strptime(rows[3], "%d/%m/%Y").to_s
        rescue ArgumentError
          date_received = nil
        end

        puts "Invalid date: #{rows[3].inspect}" unless date_received

        {
          council_reference: reference,
          address: rows[0],
          description: rows[1],
          date_received: date_received
        }
      end
    end
  end
end
