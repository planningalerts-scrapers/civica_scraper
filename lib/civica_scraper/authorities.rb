# frozen_string_literal: true

module CivicaScraper
  AUTHORITIES = {
    burwood: {
      url: "https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=219",
      period: :last7days
    },
    wollondilly: {
      url: "https://ecouncil.wollondilly.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=40801",
      period: :last7days
    },
    woollahra: {
      url: "https://eservices.woollahra.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=5270",
      period: :advertised
    },
    nambucca: {
      url:
        "https://eservices.nambucca.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=2811",
      period: :last10days
    },
    cairns: {
      url: "https://eservices.cairns.qld.gov.au/eservice/daEnquiryInit.do?nodeNum=227",
      period: :last30days
    },
    mount_gambier: {
      url: "https://ecouncil.mountgambier.sa.gov.au/eservice/daEnquiryInit.do?nodeNum=21461",
      period: :last2months
    },
    norwood: {
      url: "https://ecouncil.npsp.sa.gov.au/eservice/daEnquiryInit.do?doc_typ=155&nodeNum=10209",
      period: :lastmonth
    },
    tea_tree_gully: {
      url: "https://www.ecouncil.teatreegully.sa.gov.au/eservice/daEnquiryInit.do?nodeNum=131612",
      period: :lastmonth
    },
    loxton_waikerie: {
      url: "https://eservices.loxtonwaikerie.sa.gov.au/eservice/daEnquiryInit.do?nodeNum=2811",
      period: :lastmonth
    },
    orange: {
      url: "https://ecouncil.orange.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=24",
      period: :last30days
    },
    gawler: {
      url: "https://eservices.gawler.sa.gov.au/eservice/daEnquiryInit.do?doc_typ=4&nodeNum=3228",
      period: :lastmonth,
      # Has an incomplete SSL chain: See
      # https://www.ssllabs.com/ssltest/analyze.html?d=eservices.gawler.sa.gov.au
      disable_ssl_certificate_check: true
    }
  }.freeze
end
