# frozen_string_literal: true

module CivicaScraper
  module Page
    # A page with all the information (hopefully) about a single
    # development application
    module Detail
      def self.scrape(doc)
        rows = doc.search(".rowDataOnly > .inputField:nth-child(2)").map { |e| e.inner_text.strip }

        table = doc.at("table[summary='Tasks Associated this Development Application']")
        table_row = table.search("tr").find do |tr|
          tr.search("td")[1]&.inner_text == "Notification to Neighbours"
        end

        if table_row
          on_notice_from = table_row.search("td")[2].inner_text
          on_notice_to = table_row.search("td")[3].inner_text
        end

        {
          council_reference: rows[2],
          address: rows[0],
          description: rows[1],
          date_received: Date.strptime(rows[3], "%d/%m/%Y").to_s,
          on_notice_from: (Date.strptime(on_notice_from, "%d/%m/%Y").to_s if on_notice_from),
          on_notice_to: (Date.strptime(on_notice_to, "%d/%m/%Y").to_s if on_notice_to)
        }
      end
    end
  end
end
