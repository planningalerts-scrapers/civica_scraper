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
          on_notice_from: on_notice[:from]&.to_s,
          on_notice_to: on_notice[:to]&.to_s
        }
      end

      def self.extract_notification_period(doc)
        table = doc.at("table[summary='Tasks Associated this Development Application']")
        table_rows = table.search("tr").select do |tr|
          tr.search("td")[1]&.inner_text == "Notification to Neighbours" ||
            tr.search("td")[1]&.inner_text == "Advert-Went/Courier 30 Days"
        end

        notice_periods = table_rows.map do |table_row|
          {
            from: Date.strptime(table_row.search("td")[2].inner_text, "%d/%m/%Y"),
            to: Date.strptime(table_row.search("td")[4].inner_text, "%d/%m/%Y")
          }
        end

        return {} if notice_periods.empty?

        # Returns the most recent notice period
        notice_periods.max_by { |p| p[:from] }
      end
    end
  end
end
