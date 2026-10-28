#!/usr/bin/env ruby
# Read-only preflight. Never print the private key, JWT or authorization headers.
require 'openssl'
require 'json'
require 'base64'
require 'net/http'
require 'uri'

def b64(value)
  Base64.urlsafe_encode64(value, padding: false)
end

begin
  bundle = 'com.confusedbyme.sketch'
  now = Time.now.to_i
  header = b64(JSON.generate(alg: 'ES256', kid: ENV.fetch('ASC_KEY_ID'), typ: 'JWT'))
  payload = b64(JSON.generate(iss: ENV.fetch('ASC_ISSUER_ID'), iat: now, exp: now + 120, aud: 'appstoreconnect-v1'))
  message = "#{header}.#{payload}"
  key = OpenSSL::PKey.read(File.read(ENV.fetch('ASC_KEY_PATH')))
  der = key.sign(OpenSSL::Digest::SHA256.new, message)
  raw = OpenSSL::ASN1.decode(der).value.map { |n| [n.value.to_i.to_s(16).rjust(64, '0')].pack('H*') }.join
  token = "#{message}.#{b64(raw)}"
  uri = URI('https://api.appstoreconnect.apple.com/v1/apps')
  uri.query = URI.encode_www_form('filter[bundleId]' => bundle, 'limit' => '5')
  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "Bearer #{token}"
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 20, read_timeout: 30) { |http| http.request(request) }
  unless response.code == '200'
    reason = case response.code
             when '401' then 'App Store Connect rifiuta la chiave API: verificare Key ID, Issuer ID e P8.'
             when '403' then 'La chiave API non ha accesso sufficiente ad App Store Connect.'
             else "App Store Connect non disponibile (HTTP #{response.code})."
             end
    abort "::error::#{reason}"
  end
  apps = JSON.parse(response.body).fetch('data')
  if apps.empty?
    # Inspect only app identities relevant to this project; never print unrelated apps.
    uri.query = URI.encode_www_form('filter[name]' => 'Confused Sketch', 'limit' => '200')
    lookup = Net::HTTP::Get.new(uri)
    lookup['Authorization'] = "Bearer #{token}"
    result = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 20, read_timeout: 30) { |http| http.request(lookup) }
    if result.code == '200'
      matches = JSON.parse(result.body).fetch('data').select { |app| app.fetch('attributes').fetch('name').downcase.include?('sketch') }
      matches.each do |app|
        attributes = app.fetch('attributes')
        puts "APP_MATCH: #{attributes.fetch('name')} | Bundle ID: #{attributes.fetch('bundleId')} | App ID: #{app.fetch('id')}"
      end
      puts 'APP_MATCH: nessuna app Sketch accessibile alla chiave configurata.' if matches.empty?
    else
      puts "Ricerca per nome non disponibile (HTTP #{result.code})."
    end
    abort "::error::Nessuna app accessibile con Bundle ID #{bundle}. Creare la scheda app in App Store Connect oppure correggere il Bundle ID/accesso della chiave prima dell'upload."
  end
  puts "PASS: App Store Connect vede #{bundle} (app ID #{apps.first.fetch('id')})."
rescue KeyError, OpenSSL::OpenSSLError, JSON::ParserError, IOError, SystemCallError, Timeout::Error, SocketError => error
  abort "::error::Preflight App Store Connect fallito (#{error.class}); verificare chiave e connessione."
end
