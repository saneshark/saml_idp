# encoding: utf-8
module SamlIdp
  module Default
    NAME_ID_FORMAT = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
    X509_CERTIFICATE = File.read("spec/support/certificates/default_cert.crt") rescue nil
    FINGERPRINT = "9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D"
    SECRET_KEY = File.read("spec/support/certificates/default_key.key") rescue nil
    SERVICE_PROVIDER = {
      fingerprint: FINGERPRINT
    }

    # idp_cert_multi = {
    #   signing: {
    #     signing_cert: File.read("spec/support/certificates/idp_multi_signing_cert.crt"),
    #     signing_key: File.read("spec/support/certificates/idp_multi_signing_key.key"),
    #     password: '1234',
    #     fingerprint: "8B:06:38:EA:1C:5F:EC:2B:8E:E8:C8:62:C7:ED:C7:03:41:38:61:B5"
    #   },
    #   encryption: {
    #     encryption_cert: File.read("spec/support/certificates/idp_multi_encryption_cert.crt"),
    #     encryption_key: File.read("spec/support/certificates/idp_multi_encryption_key.key"),
    #     password: '1234',
    #     fingerprint: "40:59:79:97:B7:63:22:CA:1C:CF:1F:3E:B0:6C:6F:F7:3D:85:7C:96"
    #   },
    #   service_provider: {
    #     fingerprint: "8B:06:38:EA:1C:5F:EC:2B:8E:E8:C8:62:C7:ED:C7:03:41:38:61:B5"
    #   }
    # }

    IDP_CERT_MULTI = {
      signing: {
        signing_cert: X509_CERTIFICATE,
        signing_key: SECRET_KEY,
        password: '1234',
        fingerprint: "9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D"
      },
      encryption: {
        encryption_cert: X509_CERTIFICATE,
        encryption_key: SECRET_KEY,
        password: '1234',
        fingerprint: "9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D"
      },
      service_provider: {
        fingerprint: "9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D"
      }
    }
  end
end
