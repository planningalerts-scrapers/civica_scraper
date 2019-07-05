# frozen_string_literal: true

module CivicaScraper
  module Page
    # Page with list of development applications
    module Index
      def self.scrape(page)
        results = page.at("div.bodypanel ~ div")

        results.search("h4").each do |address|
          fields = extract_fields(address.next_sibling)

          yield(
            council_reference: fields[:council_reference],
            address: address.text,
            description: fields[:description],
            date_received: Date.strptime(fields[:date_received], "%d/%m/%Y").to_s,
            url: (page.uri + address.at("a")["href"]).to_s
          )
        end
      end

      def self.extract_fields(div)
        result = div.search("p").map do |p|
          key = p.at("span.key").inner_text
          value = p.at("span.inputField").inner_text
          [normalise_key(key, value), value]
        end
        result.to_h
      end

      def self.normalise_key(key, value)
        case key
        when "Type of Work"
          :description
        when "Application No."
          :council_reference
        when "Date Lodged"
          :date_received
        when "Applicant"
          :applicant
        when "Cost of Work"
          :cost_of_work
        when "Determination Details"
          :determination_details
        when "Determination Date"
          :determination_date
        when "Certifier"
          :certifier
        else
          raise "Unknown key: #{key} with value: #{value}"
        end
      end
    end
  end
end
