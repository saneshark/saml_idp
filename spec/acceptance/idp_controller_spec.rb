require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'IdpController' do
  scenario 'Login via default signup page' do
    Capybara.register_driver :chrome do |app|
      Capybara::Selenium::Driver.new(app, :browser => :chrome)
    end
    Capybara.current_driver = :chrome
    saml_request = make_saml_request("http://foo.example.com/saml/consume")
    visit "/saml/auth?SAMLRequest=#{CGI.escape(saml_request)}"
    
    fill_in 'Email', :with => "foo@example.com"
    fill_in 'Password', :with => "okidoki"
    click_button 'Sign in'
    click_button 'Submit'   # simulating onload
    expect(current_url).to eq('http://foo.example.com/saml/consume')
    expect(page).to have_content "foo@example.com"
  end
end
