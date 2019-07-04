module CivicaScraper
  module Authority
    module Woollahra
      def self.scrape_index_page(page, info_url)
        # The applications are grouped by suburb. So, stepping through so we can track the current suburb
        current_suburb = nil
        applications = []
        page.at('#fullcontent .bodypanel').children.each do |block|
          case block.name
          when "text", "comment", "script"
            # Do nothing
          when "h4"
            current_suburb = block.inner_text.strip
          when "table"
            record = {
              "address" => block.search('tr')[0].inner_text.strip + ", " + current_suburb + ", NSW",
              "description" => block.search('tr')[1].search('td')[2].inner_text.strip,
              "council_reference" => block.search('tr')[3].search('td')[2].inner_text.strip,
              "info_url" => info_url,
              "date_scraped" => Date.today.to_s,
            }
            on_notice_text = block.search('tr')[4].search('td')[2].inner_text.strip
            if on_notice_text =~ /(\d+\/\d+\/\d+)\s+Expires\s+(\d+\/\d+\/\d+)/
              record["on_notice_from"], record["on_notice_to"] = $~[1..2]
            else
              raise "Unexpected form for text: #{on_notice_text}"
            end

            yield record
          else
            raise "Unexpected type: #{block.name}"
          end
        end
      end

      def self.scrape_and_save
        # Doesn't seem to work without that nodeNum. I wonder what it is.
        url = "https://eservices.woollahra.nsw.gov.au/eservice/advertisedDAs.do?&orderBy=suburb&nodeNum=5265"
        # We can't give a link directly to an application. Bummer. So, giving link to the search page
        info_url = "https://eservices.woollahra.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=5270"

        agent = Mechanize.new
        page = agent.get(url)

        scrape_index_page(page, info_url) do |record|
          CivicaScraper.save(record)
        end
      end
    end
  end
end
