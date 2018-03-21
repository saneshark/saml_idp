require 'spec_helper'
module SamlIdp
  shared_examples "MetadataBuilder" do |fingerprint|
    it "has a valid fresh" do
      expect(subject.fresh).to_not be_empty
    end

    it "signs valid xml" do
      expect(Saml::XML::Document.parse(subject.signed).valid_signature?(fingerprint)).to be_truthy
    end

    it "includes logout element" do
      subject.configurator.single_logout_service_post_location = 'https://example.com/saml/logout'
      expect(subject.fresh).to match('<SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://example.com/saml/logout"/>')
    end

    context "technical contact" do
      before do
        subject.configurator.technical_contact.company       = nil
        subject.configurator.technical_contact.given_name    = nil
        subject.configurator.technical_contact.sur_name      = nil
        subject.configurator.technical_contact.telephone     = nil
        subject.configurator.technical_contact.email_address = nil
      end

      it "all fields" do
        subject.configurator.technical_contact.company       = "ACME Corporation"
        subject.configurator.technical_contact.given_name    = "Road"
        subject.configurator.technical_contact.sur_name      = "Runner"
        subject.configurator.technical_contact.telephone     = "1-800-555-5555"
        subject.configurator.technical_contact.email_address = "acme@example.com"

        expect(subject.fresh).to match('<ContactPerson contactType="technical"><Company>ACME Corporation</Company><GivenName>Road</GivenName><SurName>Runner</SurName><EmailAddress>mailto:acme@example.com</EmailAddress><TelephoneNumber>1-800-555-5555</TelephoneNumber></ContactPerson>')
      end

      it "no fields" do
        expect(subject.fresh).to match('<ContactPerson contactType="technical"></ContactPerson>')
      end

      it "just email" do
        subject.configurator.technical_contact.email_address = "acme@example.com"
        expect(subject.fresh).to match('<ContactPerson contactType="technical"><EmailAddress>mailto:acme@example.com</EmailAddress></ContactPerson>')
      end

    end

    it "includes logout element as HTTP Redirect" do
      subject.configurator.single_logout_service_redirect_location = 'https://example.com/saml/logout'
      expect(subject.fresh).to match('<SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://example.com/saml/logout"/>')
    end
  end

  describe MetadataBuilder do
    context "with multi_cert true" do
      before(:each) { SamlIdp.config.idp_multi_cert = Default::IDP_MULTI_CERT }
      include_examples "MetadataBuilder", Default::IDP_MULTI_CERT_SIGNING_FINGERPRINT
    end

    context "with multi_cert false" do
      before(:each) { SamlIdp.config.idp_multi_cert = nil }
      include_examples "MetadataBuilder", Default::FINGERPRINT
    end
  end
end
