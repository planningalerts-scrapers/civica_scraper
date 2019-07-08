module CivicaScraper
  module Authority
    module Woollahra
      def self.scrape_and_save
        CivicaScraper.scrape_and_save_period(
          url: "https://eservices.woollahra.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=5270",
          period: :advertised
        )
      end
    end
  end
end
