module SamlIdp
  module Utils
    def remove_headers_and_footer(string)
      string.to_s
        .gsub(/-----BEGIN CERTIFICATE-----/,"")
        .gsub(/-----END CERTIFICATE-----/,"")
        .gsub(/\n/, "")
    end
  end
end
