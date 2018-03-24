# encoding: utf-8
require 'spec_helper'
require 'saml_idp/utils'

shared_examples 'SamlIdp::Controller' do |options|
  it "should find the SAML ACS URL" do
    requested_saml_acs_url = "https://example.com/saml/consume"
    params[:SAMLRequest] = make_saml_request(requested_saml_acs_url)
    expect(validate_saml_request).to eq(true)
    expect(saml_acs_url).to eq(requested_saml_acs_url)
  end

  context "SAML Responses" do
    let(:principal) { double email_address: "foo@example.com" }
    let (:encryption_opts) do
      {
        cert: SamlIdp::Utils.remove_headers_and_footer(SamlIdp::Default::X509_CERTIFICATE),
        block_encryption: 'aes256-cbc',
        key_transport: 'rsa-oaep-mgf1p',
      }
    end

    context "unsolicited Response" do
      it "should create a SAML Response" do
        saml_response = encode_response(principal, { audience_uri: 'http://example.com/issuer', issuer_uri: 'http://example.com', acs_url: 'https://foo.example.com/saml/consume' })
        response = OneLogin::RubySaml::Response.new(saml_response)
        expect(response.name_id).to eq("foo@example.com")
        expect(response.issuers.first).to eq("http://example.com")
        response.settings = saml_settings
        expect(response.is_valid?).to be_truthy
      end
    end

    context "solicited Response" do
      before(:each) do
        params[:SAMLRequest] = make_saml_request
        expect(validate_saml_request).to eq(true)
      end

      it "should create a SAML Response" do
        saml_response = encode_response(principal)
        response = OneLogin::RubySaml::Response.new(saml_response)
        expect(response.name_id).to eq("foo@example.com")
        expect(response.issuers.first).to eq("http://example.com")
        response.settings = saml_settings
        expect(response.is_valid?).to be_truthy
      end

      it "should create a SAML Logout Response" do
        params[:SAMLRequest] = make_saml_logout_request
        expect(validate_saml_request).to eq(true)
        expect(saml_request.logout_request?).to eq true
        saml_response = encode_response(principal)
        response = OneLogin::RubySaml::Logoutresponse.new(saml_response, saml_settings)
        expect(response.validate).to eq(true)
        expect(response.issuer).to eq("http://example.com")
      end


      [:sha1, :sha256, :sha384, :sha512].each do |algorithm_name|
        next if options[:skip].include?(algorithm_name)

        it "should create a SAML Response using the #{algorithm_name} algorithm" do
          self.algorithm = algorithm_name
          saml_response = encode_response(principal)
          response = OneLogin::RubySaml::Response.new(saml_response)
          expect(response.name_id).to eq("foo@example.com")
          expect(response.issuers.first).to eq("http://example.com")
          response.settings = saml_settings
          expect(response.is_valid?).to be_truthy
        end

        it "should encrypt SAML Response assertion" do
          self.algorithm = algorithm_name
          saml_response = encode_response(principal, encryption: encryption_opts)
          resp_settings = saml_settings
          resp_settings.private_key = SamlIdp::Default::SECRET_KEY
          response = OneLogin::RubySaml::Response.new(saml_response, settings: resp_settings)
          expect(response.document.to_s).to_not match("foo@example.com")
          expect(response.decrypted_document.to_s).to match("foo@example.com")
          expect(response.name_id).to eq("foo@example.com")
          expect(response.issuers.first).to eq("http://example.com")
          expect(response.is_valid?).to be_truthy
        end
      end
    end
  end
end

describe SamlIdp::Controller do
  include SamlIdp::Controller

  def render(*)
  end

  def head(*)
  end

  def params
    @params ||= {}
  end

  context "with multi_cert true" do
    before(:each) { SamlIdp.config.idp_cert_multi = SamlIdp::Default::IDP_CERT_MULTI }
    include_examples "SamlIdp::Controller", skip: %i[sha1 sha384 sha512]
  end

  context "with multi_cert false" do
    before(:each) { SamlIdp.config.idp_cert_multi = nil }
    include_examples "SamlIdp::Controller", skip: []
  end
end
