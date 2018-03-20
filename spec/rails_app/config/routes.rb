RailsApp::Application.routes.draw do
  get '/saml/auth' => 'saml_idp#new'
  get '/saml/metadata' => 'saml_idp#show'
  post '/saml/auth' => 'saml_idp#create'
  post '/saml/consume' => 'saml#consume'
end
