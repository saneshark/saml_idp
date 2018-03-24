require 'spec_helper'
module SamlIdp
  shared_examples "MetadataBuilder" do |fingerprint|
    it "has a valid fresh" do
      expect(subject.fresh).to_not be_empty
    end

    it "signs valid xml" do
      expect(Saml::XML::Document.parse(subject.signed).valid_signature?(fingerprint)).to be_truthy
    end

    it "includes entity attribute elements" do
      subject.configurator.entity_attributes = [{
        name: "urn:oasis:names:tc:SAML:attribute:assurance-certification",
        name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
        values_array: [
          "http://idmanagement.gov/ns/assurance/loa/1",
          "http://idmanagement.gov/ns/assurance/loa/2",
          "http://idmanagement.gov/ns/assurance/loa/3"
        ]
      }]

      expect(subject.fresh).to match('<md:Extensions><mdattr:EntityAttributes xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="urn:oasis:names:tc:SAML:attribute:assurance-certification" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic"><saml:AttributeValue xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xsi:type="xs:string">http://idmanagement.gov/ns/assurance/loa/1</saml:AttributeValue><saml:AttributeValue xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xsi:type="xs:string">http://idmanagement.gov/ns/assurance/loa/2</saml:AttributeValue><saml:AttributeValue xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xsi:type="xs:string">http://idmanagement.gov/ns/assurance/loa/3</saml:AttributeValue></saml:Attribute></mdattr:EntityAttributes></md:Extensions>')
    end

    it "includes custom name id format elements" do
      subject.configurator.name_id.formats = {
        "1.1" => {
          unspecified: -> (principal) { principal.birth_date }
        },
        "2.0" => {
          persistent: -> (principal) { principal.birth_date },
          transient: -> (principal) { principal.birth_date }
        }
      }
      expect(subject.fresh).to match('<md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified</md:NameIDFormat><md:NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:persistent</md:NameIDFormat><md:NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</md:NameIDFormat>')
    end

    context "url elements" do
      it "includes artifact resolution service element" do
        subject.configurator.artifact_resolution_service_location = "https://api.idmelabs.com/saml/ArtifactResolutionService"
        expect(subject.fresh).to match('<md:ArtifactResolutionService Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP" Location="https://api.idmelabs.com/saml/ArtifactResolutionService" index="0" isDefault="false"/>')
      end

      it "includes logout element" do
        subject.configurator.single_logout_service_post_location = 'https://example.com/saml/logout'
        expect(subject.fresh).to match('<md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://example.com/saml/logout"/>')
      end

      it "includes logout element as HTTP Redirect" do
        subject.configurator.single_logout_service_redirect_location = 'https://example.com/saml/logout'
        expect(subject.fresh).to match('<md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://example.com/saml/logout"/>')
      end

      it "includes logout element" do
        subject.configurator.single_sign_on_service_post_location = 'https://example.com/saml/logout'
        expect(subject.fresh).to match('<md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://example.com/saml/logout"/>')
      end

      it "includes logout element as HTTP Redirect" do
        subject.configurator.single_sign_on_service_redirect_location = 'https://example.com/saml/logout'
        expect(subject.fresh).to match('<md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://example.com/saml/logout"/>')
      end
    end

    context "attributes" do
      it "includes attribute elements" do
        subject.configurator.attributes =
        {
          "Birth Date" => {
            name: "birth_date",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Birth Date"
          },
          "City" => {
            name: "city",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "City"
          },
          "Country" => {
            name: "country",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Country"
          },
          "Email" => {
            name: "email",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Email"
          },
          "First Name" => {
            name: "fname",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "First Name"
          },
          "Full Name" => {
            name: "full_name",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Full Name"
          },
          "Full SSN" => {
            name: "social",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Full SSN"
          },
          "Gender" => {
            name: "gender",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Gender"
          },
          "Last 4 of SSN" => {
            name: "social_short",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Last 4 of SSN"
          },
          "Last Name" => {
            name: "lname",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Last Name"
          },
          "Middle Name" => {
            name: "mname",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Middle Name"
          },
          "Phone" => {
            name: "phone",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Phone"
          },
          "Postal Code" => {
            name: "zip",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Postal Code"
          },
          "State" => {
            name: "state",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "State"
          },
          "Street" => {
            name: "street",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Street"
          },
          "Suffix" => {
            name: "suffix",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Suffix"
          },
          "Verified credentials" => {
            name: "credentials",
            name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Verified credentials"
          }
        }

        expect(subject.fresh).to match('<saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="birth_date" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Birth Date"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="city" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="City"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="country" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Country"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Email"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="fname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="First Name"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="full_name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Full Name"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="social" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Full SSN"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="gender" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Gender"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="social_short" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Last 4 of SSN"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="lname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Last Name"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="mname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Middle Name"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="phone" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Phone"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="zip" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Postal Code"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="state" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="State"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="street" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Street"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="suffix" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Suffix"/><saml:Attribute xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Name="credentials" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" FriendlyName="Verified credentials"/>')
      end
    end

    context "technical contact" do
      before do
        subject.configurator.technical_contact.company       = nil
        subject.configurator.technical_contact.given_name    = nil
        subject.configurator.technical_contact.sur_name      = nil
        subject.configurator.technical_contact.telephone     = nil
        subject.configurator.technical_contact.email_address = nil
      end

      it "has all fields" do
        subject.configurator.technical_contact.company       = "ACME Corporation"
        subject.configurator.technical_contact.given_name    = "Road"
        subject.configurator.technical_contact.sur_name      = "Runner"
        subject.configurator.technical_contact.telephone     = "1-800-555-5555"
        subject.configurator.technical_contact.email_address = "acme@example.com"


        expect(subject.fresh).to match('<md:ContactPerson contactType="technical"><md:Company>ACME Corporation</md:Company><md:GivenName>Road</md:GivenName><md:SurName>Runner</md:SurName><md:EmailAddress>mailto:acme@example.com</md:EmailAddress><md:TelephoneNumber>1-800-555-5555</md:TelephoneNumber></md:ContactPerson>')
      end

      it "has no fields" do
        expect(subject.fresh).to match('<md:ContactPerson contactType="technical"></md:ContactPerson>')
      end

      it "has just email" do
        subject.configurator.technical_contact.email_address = "acme@example.com"
        expect(subject.fresh).to match('<md:ContactPerson contactType="technical"><md:EmailAddress>mailto:acme@example.com</md:EmailAddress></md:ContactPerson>')
      end
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
