module SamlIdp
  module Utils
    extend self
    
    def remove_headers_and_footer(string)
      string.to_s
        .gsub(/-----BEGIN CERTIFICATE-----/,"")
        .gsub(/-----END CERTIFICATE-----/,"")
        .gsub(/\n/, "")
    end

    # This might prove handy, but commenting it out for now.
    # def calc_fingerprint(string)
    #   require 'openssl'
    #   cert = OpenSSL::X509::Certificate.new(string)
    #   OpenSSL::Digest::SHA1.hexdigest(cert.to_der).scan(/../).join(':')
    # end
  end
end
