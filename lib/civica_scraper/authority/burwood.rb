require 'scraperwiki'
require 'mechanize'
require 'date'

module CivicaScraper
  module Authority
    module Burwood
      def self.scrape_table(agent, scrape_url, comment_url)
      #  puts "Scraping " + scrape_url
        doc = agent.get(scrape_url)
        rows = doc.search('.rowDataOnly > .inputField:nth-child(2)').map { |e| e.inner_text.strip }
        reference = rows[2]
        date_received = Date.strptime(rows[3], '%d/%m/%Y').to_s rescue nil
        puts "Invalid date: #{rows[3].inspect}" unless date_received

        record = {
          'council_reference' => reference,
          'address' => rows[0],
          'description' => rows[1],
          'info_url' => "https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=219",
          'comment_url' => comment_url + CGI::escape("Development Application Enquiry: " + reference),
          'date_scraped' => Date.today.to_s,
          'date_received' => date_received
        }
        puts "Saving record " + record['council_reference'] + ' - ' + record['address']
      #    puts record
        ScraperWiki.save_sqlite(['council_reference'], record)
      end

      def self.scrape_and_save
        date = Date.today
        dateTo   = Date.new(date.year, date.month, date.day).strftime('%d/%m/%Y')
        date = Date.today - 7
        dateFrom = Date.new(date.year, date.month, date.day).strftime('%d/%m/%Y')

        comment_url = 'mailto:council@burwood.nsw.gov.au?subject='
        starting_url = 'https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=219'
        search_result_url = 'https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryDetails.do?index='

        # Grab the starting page and go into each link to get a more reliable data format.
        agent = Mechanize.new
        page = agent.get(starting_url)
        form = page.form_with(name: "daEnquiryForm")
        form['lodgeRangeType'] = 'on'
        form['dateFrom'] = dateFrom
        form['dateTo']   = dateTo
        page = form.submit()

        (0..page.search('.non_table_headers').size - 1).each do |i|
          scrape_url = search_result_url + i.to_s
          scrape_table(agent, scrape_url, comment_url)
        end
      end
    end
  end
end
