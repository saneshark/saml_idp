require 'builder'
module SamlIdp
  class SignatureBuilder
    include Utils
    attr_accessor :signed_info_builder

    def initialize(signed_info_builder)
      self.signed_info_builder = signed_info_builder
    end

    def raw
      builder = Builder::XmlMarkup.new
      builder.tag! "ds:Signature", "xmlns:ds" => "http://www.w3.org/2000/09/xmldsig#" do |signature|
        signature << signed_info
        signature.tag! "ds:SignatureValue", signature_value
        signature.KeyInfo xmlns: "http://www.w3.org/2000/09/xmldsig#" do |key_info|
          key_info.tag! "ds:X509Data" do |x509|
            x509.tag! "ds:X509Certificate", scrubbed_signing_certificate
          end
        end
      end
    end

    def scrubbed_signing_certificate
      remove_headers_and_footer SamlIdp.config.signing_certificate
    end
    private :scrubbed_signing_certificate

    def signed_info
      signed_info_builder.raw
    end
    private :signed_info

    def signature_value
      signed_info_builder.signed
    end
    private :signature_value
  end
end
