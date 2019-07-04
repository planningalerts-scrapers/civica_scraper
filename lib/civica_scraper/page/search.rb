# frozen_string_literal: true

module CivicaScraper
  module Page
    # The general DA search page
    module Search
      # Return page with applications submitted between these dates
      def self.period(page, date_from, date_to)
        form = page.form_with(name: "daEnquiryForm")
        form.dateFrom = date_from.strftime("%d/%m/%Y")
        form.dateTo   = date_to.strftime("%d/%m/%Y")
        form.submit
      end
    end
  end
end
