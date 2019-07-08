# frozen_string_literal: true

module CivicaScraper
  module Page
    # A page with all the information (hopefully) about a single
    # development application
    module Detail
      def self.scrape(doc)
        rows = doc.search(".rowDataOnly > .inputField:nth-child(2)").map { |e| e.inner_text.strip }

        on_notice = extract_notification_period(doc)

        {
          council_reference: rows[2],
          address: rows[0].squeeze(" "),
          description: rows[1],
          date_received: Date.strptime(rows[3], "%d/%m/%Y").to_s,
          on_notice_from: (Date.strptime(on_notice[:from], "%d/%m/%Y").to_s if on_notice[:from]),
          on_notice_to: (Date.strptime(on_notice[:to], "%d/%m/%Y").to_s if on_notice[:to])
        }
      end

      def self.extract_notification_period(doc)
        table = doc.at("table[summary='Tasks Associated this Development Application']")
        table_rows = table.search("tr").select do |tr|
          tr.search("td")[1]&.inner_text == "Notification to Neighbours"
        end

        notice_periods = table_rows.map do |table_row|
          {
            from: table_row.search("td")[2].inner_text,
            to: table_row.search("td")[3].inner_text
          }
        end

        # For the time being return the last
        if notice_periods.empty?
          {
            from: nil, to: nil
          }
        else
          # Returns the most recent notice period
          notice_periods.max_by { |p| p[:from] }
        end
      end
    end
  end
end
