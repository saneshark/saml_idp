# encoding: utf-8
require 'ostruct'
module SamlIdp
  class Configurator
    attr_accessor :idp_multi_cert
    attr_accessor :x509_certificate
    attr_accessor :secret_key
    attr_accessor :password
    attr_accessor :algorithm
    attr_accessor :organization_name
    attr_accessor :organization_url
    attr_accessor :base_saml_location
    attr_accessor :entity_id
    attr_accessor :reference_id_generator
    attr_accessor :attribute_service_location
    attr_accessor :single_service_post_location
    attr_accessor :single_logout_service_post_location
    attr_accessor :single_logout_service_redirect_location
    attr_accessor :attributes
    attr_accessor :service_provider
    attr_accessor :session_expiry

    def initialize
      self.idp_multi_cert = Default::IDP_MULTI_CERT
      self.x509_certificate = Default::X509_CERTIFICATE
      self.secret_key = Default::SECRET_KEY
      self.algorithm = :sha1

      self.reference_id_generator = ->() { UUID.generate }
      self.service_provider = OpenStruct.new
      self.service_provider.finder = ->(_) { Default::SERVICE_PROVIDER }
      self.service_provider.metadata_persister = ->(id, settings) {  }
      self.service_provider.persisted_metadata_getter = ->(id, service_provider) {  }
      self.session_expiry = 0
      self.attributes = {}
    end

    def signing_certificate
      multi_cert? ? idp_multi_cert.dig(:signing, :signing_cert) : x509_certificate
    end

    def signing_secret_key
      multi_cert? ? idp_multi_cert.dig(:signing, :signing_key) : secret_key
    end

    def signing_password
      multi_cert? ? idp_multi_cert.dig(:signing, :password) : password
    end

    def encryption_certificate
      multi_cert? ? idp_multi_cert.dig(:encryption, :encryption_cert) : x509_certificate
    end

    def encryption_secret_key
      multi_cert? ? idp_multi_cert.dig(:encryption, :encryption_key) : secret_key
    end

    def encryption_password
      multi_cert? ? idp_multi_cert.dig(:encryption, :password) : password
    end

    # formats
    # getter
    def name_id
      @name_id ||= OpenStruct.new
    end

    def technical_contact
      @technical_contact ||= TechnicalContact.new
    end

    def multi_cert?
      idp_multi_cert.present?
    end

    class TechnicalContact < OpenStruct
      def mail_to_string
        "mailto:#{email_address}" if email_address.to_s.length > 0
      end
    end
  end
end
