require 'saml_idp/name_id_formatter'
require 'saml_idp/attribute_decorator'
require 'saml_idp/algorithmable'
require 'saml_idp/signable'
module SamlIdp
  class MetadataBuilder
    include Algorithmable
    include Signable
    include Utils
    attr_accessor :configurator

    def initialize(configurator = SamlIdp.config)
      self.configurator = configurator
    end

    def fresh
      builder = Builder::XmlMarkup.new
      generated_reference_id do
        builder.tag! "md:EntityDescriptor", "xmlns:md" => Saml::XML::Namespaces::METADATA,
          #TODO: implement validUntil: <Date>
          ID: reference_string,
          entityID: entity_id do |entity|
            sign entity
            build_entity_attributes(entity) if configurator.entity_attributes.any?

            entity.IDPSSODescriptor protocolSupportEnumeration: protocol_enumeration do |descriptor|
              build_key_descriptor descriptor
              build_key_descriptor(descriptor, type: "encryption", cert: scrubbed_encryption_certificate) if configurator.multi_cert?
              descriptor.SingleLogoutService Binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
                Location: single_logout_service_post_location
              descriptor.SingleLogoutService Binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect",
                Location: single_logout_service_redirect_location
              build_name_id_formats descriptor
              descriptor.SingleSignOnService Binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect",
                Location: single_service_post_location
              #build_attribute descriptor
            end

            build_organization entity
            build_contact entity
          end
      end
    end
    alias_method :raw, :fresh

    private

    def build_entity_attributes(el)
      el.tag! "md:Extensions" do |extensions|
        extensions.tag! "mdattr:EntityAttributes",
          "xmlns:mdattr" => Saml::XML::Namespaces::METADATA_ATTRIBUTE do |entity_attributes|
            configurator.entity_attributes.each do |entity_attribute|
              entity_attributes.tag! "saml:Attribute",
                "xmlns:saml" => Saml::XML::Namespaces::ASSERTION,
                Name: entity_attribute[:name],
                NameFormat: entity_attribute[:name_format] do
                  entity_attribute[:values_array].each do |value|
                    entity_attributes.tag! "saml:AttributeValue", {"xmlns:xs" => Saml::XML::Namespaces::SCHEMA,
                      "xmlns:xsi" => Saml::XML::Namespaces::SCHEMA_INSTANCE,
                      "xsi:type" => "xs:string"},
                      value
                  end
                end
            end
         end
      end
    end

    def build_key_descriptor(el, type: "signing", cert: scrubbed_signing_certificate)
      el.KeyDescriptor use: type do |key_descriptor|
        key_descriptor.KeyInfo xmlns: Saml::XML::Namespaces::SIGNATURE do |key_info|
          key_info.X509Data do |x509|
            x509.X509Certificate cert
          end
        end
      end
    end

    def build_name_id_formats(el)
      name_id_formats.each do |format|
        el.NameIDFormat format
      end
    end

    # def build_attribute(el)
    #   attributes.each do |attribute|
    #     el.tag! "saml:Attribute",
    #       FriendlyName: attribute.friendly_name do |attribute_xml|
    #         attribute.values.each do |value|
    #           attribute_xml.tag! "saml:AttributeValue", value
    #         end
    #       end,
    #       Name: attribute.name,
    #       NameFormat: attribute.name_format
    #   end
    # end

    def build_organization(el)
      el.Organization do |organization|
        organization.OrganizationName organization_name, "xml:lang" => "en"
        organization.OrganizationDisplayName organization_name, "xml:lang" => "en"
        organization.OrganizationURL organization_url, "xml:lang" => "en"
      end
    end

    def build_contact(el)
      el.ContactPerson contactType: "technical" do |contact|
        contact.Company         technical_contact.company         if technical_contact.company
        contact.GivenName       technical_contact.given_name      if technical_contact.given_name
        contact.SurName         technical_contact.sur_name        if technical_contact.sur_name
        contact.EmailAddress    technical_contact.mail_to_string  if technical_contact.mail_to_string
        contact.TelephoneNumber technical_contact.telephone       if technical_contact.telephone
      end
    end

    def reference_string
      "_#{reference_id}"
    end

    def entity_id
      configurator.entity_id.presence || configurator.base_saml_location
    end

    def protocol_enumeration
      Saml::XML::Namespaces::PROTOCOL
    end

    def attributes
      @attributes ||= configurator.attributes.inject([]) do |list, (key, opts)|
        opts[:friendly_name] = key
        list << AttributeDecorator.new(opts)
        list
      end
    end

    def name_id_formats
      @name_id_formats ||= NameIdFormatter.new(configurator.name_id.formats).all
    end

    def raw_algorithm
      configurator.algorithm
    end

    def scrubbed_signing_certificate
      remove_headers_and_footer SamlIdp.config.signing_certificate
    end

    def scrubbed_encryption_certificate
      SamlIdp.config.multi_cert? ? remove_headers_and_footer(SamlIdp.config.encryption_certificate) : nil
    end

    %w[
      support_email
      organization_name
      organization_url
      attribute_service_location
      single_service_post_location
      single_logout_service_post_location
      single_logout_service_redirect_location
      technical_contact
    ].each do |delegatable|
      define_method(delegatable) do
        configurator.public_send delegatable
      end
      private delegatable
    end
  end
end
