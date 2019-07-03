require 'mechanize'
require 'date'

module CivicaScraper
  module Authority
    module Burwood
      def self.scrape_table(doc, info_url)
        rows = doc.search('.rowDataOnly > .inputField:nth-child(2)').map { |e| e.inner_text.strip }
        reference = rows[2]
        date_received = Date.strptime(rows[3], '%d/%m/%Y').to_s rescue nil
        puts "Invalid date: #{rows[3].inspect}" unless date_received

        record = {
          'council_reference' => reference,
          'address' => rows[0],
          'description' => rows[1],
          'info_url' => info_url,
          'date_scraped' => Date.today.to_s,
          'date_received' => date_received
        }
        CivicaScraper.save(record)
      end

      def self.scrape_and_save
        date_from = Date.today - 7
        date_to = Date.today

        general_search_url = 'https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=219'
        search_result_url = 'https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryDetails.do?index='

        # Grab the starting page and go into each link to get a more reliable data format.
        agent = Mechanize.new
        page = agent.get(general_search_url)
        form = page.form_with(name: "daEnquiryForm")
        form['lodgeRangeType'] = 'on'
        form['dateFrom'] = date_from.strftime('%d/%m/%Y')
        form['dateTo']   = date_to.strftime('%d/%m/%Y')
        page = form.submit()

        (0..page.search('.non_table_headers').size - 1).each do |i|
          doc = agent.get(search_result_url + i.to_s)
          scrape_table(doc, general_search_url)
        end
      end
    end
  end
end
