module CivicaScraper
  module Authority
    module Nambucca
      def self.scrape_and_save
        date = Date.today
        dateTo   = Date.new(date.year, date.month, date.day).strftime('%d/%m/%Y')
        date = Date.today - 10
        dateFrom = Date.new(date.year, date.month, date.day).strftime('%d/%m/%Y')

        info_url = 'https://eservices.nambucca.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=2811'

        # Grab the starting page and put in the date and her we go
        agent = Mechanize.new
        page = agent.get(info_url)
        form = page.form_with(name: "daEnquiryForm")
        form['lodgeRangeType'] = 'on'
        form['dateFrom'] = dateFrom
        form['dateTo']   = dateTo
        page = form.submit()

        headings = page.at('.bodypanel ~ div').search('h2')
        (0..headings.size - 1).each do |i|
          heading = headings[i]
          d = heading.next_sibling
          date_received = Date.strptime(d.at('span:contains("Date Lodged") ~ span').inner_text, '%d/%m/%Y').to_s rescue nil

          record = {
            'council_reference' => d.at('span:contains("Application No.") ~ span').inner_text,
            'address' => heading.inner_text,
            'description' => d.at('span:contains("Type of Work") ~ span').inner_text,
            'info_url' => info_url,
            'date_scraped' => Date.today.to_s,
            'date_received' => date_received
          }

          CivicaScraper.save(record)
        end
      end
    end
  end
end
