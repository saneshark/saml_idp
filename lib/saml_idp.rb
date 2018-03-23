# encoding: utf-8
module SamlIdp
  require 'active_support/all'
  require 'saml_idp/utils'
  require 'saml_idp/saml_response'
  require 'saml_idp/xml_security'
  require 'saml_idp/configurator'
  require 'saml_idp/controller'
  require 'saml_idp/default'
  require 'saml_idp/metadata_builder'
  require 'saml_idp/version'
  require 'saml_idp/engine' if defined?(::Rails) && Rails::VERSION::MAJOR > 2

  def self.config
    @config ||= SamlIdp::Configurator.new
  end

  def self.configure
    yield config
  end

  def self.metadata
    @metadata ||= MetadataBuilder.new(config)
  end
end

# TODO Needs extraction out
module Saml
  module XML
    module Namespaces
      METADATA = "urn:oasis:names:tc:SAML:2.0:metadata"
      METADATA_ATTRIBUTE = "urn:oasis:names:tc:SAML:metadata:attribute"
      SCHEMA = "http://www.w3.org/2001/XMLSchema"
      SCHEMA_INSTANCE = "http://www.w3.org/2001/XMLSchema-instance"
      ASSERTION = "urn:oasis:names:tc:SAML:2.0:assertion"
      SIGNATURE = "http://www.w3.org/2000/09/xmldsig#"
      PROTOCOL = "urn:oasis:names:tc:SAML:2.0:protocol"

      module Statuses
        SUCCESS = "urn:oasis:names:tc:SAML:2.0:status:Success"
      end

      module Consents
        UNSPECIFIED = "urn:oasis:names:tc:SAML:2.0:consent:unspecified"
      end

      module AuthnContext
        module ClassRef
          PASSWORD = "urn:oasis:names:tc:SAML:2.0:ac:classes:Password"
          PASSWORD_PROTECTED = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
        end
      end

      module Methods
        BEARER = "urn:oasis:names:tc:SAML:2.0:cm:bearer"
      end

      module Formats
        module Attr
          URI = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
        end

        module NameId
          BASIC = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
          EMAIL_ADDRESS = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
          PERSISTENT = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
          TRANSIENT = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"
          UNSPECIFIED = "urn:oasis:names:tc:SAML:2.0:nameid-format:unspecified"
        end
      end
    end

    class Document < Nokogiri::XML::Document
      def signed?
        !!xpath("//ds:Signature", ds: signature_namespace).first
      end

      def valid_signature?(fingerprint)
        signed? &&
          signed_document.validate(fingerprint, :soft)
      end

      def signed_document
        SamlIdp::XMLSecurity::SignedDocument.new(to_xml)
      end

      def signature_namespace
        Namespaces::SIGNATURE
      end

      def to_xml
        super(
          save_with: Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION
        ).strip
      end
    end
  end
end
