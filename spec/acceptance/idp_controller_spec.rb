require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'IdpController' do
  scenario 'Login via default signup page' do
    saml_request = make_saml_request("http://foo.example.com/saml/consume")
    visit "/saml/auth?SAMLRequest=#{CGI.escape(saml_request)}"
    fill_in 'Email', :with => "foo@example.com"
    fill_in 'Password', :with => "okidoki"
    click_button 'Sign in'
    click_button 'Submit'   # simulating onload
    expect(current_url).to eq('http://foo.example.com/saml/consume')
    expect(page).to have_content "foo@example.com"
  end

  scenario 'Fetch metadata via show' do
    visit '/saml/metadata'
    expect(current_url).to eq('https://app.example.com/saml/metadata')
    settings = OneLogin::RubySaml::IdpMetadataParser.new.parse(page.body)
    expect(settings.assertion_consumer_service_binding)
      .to eq("urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST")
    expect(settings.attribute_consuming_service.attributes)
      .to eq([])
    expect(settings.attribute_consuming_service.index).to eq("1")
    expect(settings.compress_request).to eq(true)
    expect(settings.compress_response).to eq(true)
    expect(settings.double_quote_xml_attribute_values).to eq(false)
    expect(settings.idp_attribute_names).to eq(["email-address"])
    expect(settings.idp_cert).to be_a(String)
    expect(settings.idp_cert_fingerprint)
      .to eq("9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D")
    expect(settings.idp_cert_fingerprint_algorithm)
      .to eq('http://www.w3.org/2000/09/xmldsig#sha1')
    expect(settings.idp_cert_multi).to eq(nil)
    expect(settings.idp_entity_id).to eq("")
    expect(settings.idp_slo_target_url).to eq("https://example.com/saml/logout")
    expect(settings.idp_sso_target_url).to eq("")
    expect(settings.name_identifier_format)
      .to eq("urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress")
    expect(settings.security).to eq(
      {
        authn_requests_signed: false,
        logout_requests_signed: false,
        logout_responses_signed: false,
        want_assertions_signed: false,
        want_assertions_encrypted: false,
        want_name_id: false,
        metadata_signed: false,
        embed_sign: false,
        digest_method: "http://www.w3.org/2000/09/xmldsig#sha1",
        signature_method: "http://www.w3.org/2000/09/xmldsig#rsa-sha1"
      }
    )
    expect(settings.single_logout_service_binding)
      .to eq("urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect")
    expect(settings.soft).to eq(true)
  end
end
