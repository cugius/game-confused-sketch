#!/usr/bin/env ruby
# Creates the Game Center achievements in App Store Connect from assets/gamecenter/definitions.json.
# Dry run by default: prints the plan and changes nothing. Pass --apply to create what is missing.
# Idempotent: achievements whose vendorIdentifier already exists are skipped. Never prints the key or tokens.
require 'openssl'
require 'json'
require 'base64'
require 'net/http'
require 'uri'

BUNDLE = 'com.confusedbyme.confusedsketch'
API = 'https://api.appstoreconnect.apple.com'
# Game Center locales used by the game → App Store Connect locale codes.
LOCALES = { 'it' => 'it', 'en' => 'en-US', 'es' => 'es-ES', 'fr' => 'fr-FR', 'de' => 'de-DE', 'ja' => 'ja' }.freeze
DEFINITIONS = File.expand_path('../assets/gamecenter/definitions.json', __dir__)

def b64(value)
  Base64.urlsafe_encode64(value, padding: false)
end

def token
  now = Time.now.to_i
  header = b64(JSON.generate(alg: 'ES256', kid: ENV.fetch('ASC_KEY_ID'), typ: 'JWT'))
  payload = b64(JSON.generate(iss: ENV.fetch('ASC_ISSUER_ID'), iat: now, exp: now + 900, aud: 'appstoreconnect-v1'))
  message = "#{header}.#{payload}"
  key = OpenSSL::PKey.read(File.read(ENV.fetch('ASC_KEY_PATH')))
  der = key.sign(OpenSSL::Digest::SHA256.new, message)
  raw = OpenSSL::ASN1.decode(der).value.map { |n| [n.value.to_i.to_s(16).rjust(64, '0')].pack('H*') }.join
  "#{message}.#{b64(raw)}"
end

def asc(method, path, query: nil, body: nil)
  uri = URI("#{API}#{path}")
  uri.query = URI.encode_www_form(query) if query
  request = method == :get ? Net::HTTP::Get.new(uri) : Net::HTTP::Post.new(uri)
  request['Authorization'] = "Bearer #{@token}"
  if body
    request['Content-Type'] = 'application/json'
    request.body = JSON.generate(body)
  end
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 20, read_timeout: 60) { |http| http.request(request) }
  unless response.code.start_with?('2')
    detail = begin
      JSON.parse(response.body).fetch('errors', []).map { |e| e['detail'] || e['title'] }.compact.join(' ')
    rescue JSON::ParserError
      ''
    end
    raise "HTTP #{response.code} su #{path}#{detail.empty? ? '' : ": #{detail}"}"
  end
  response.body.to_s.empty? ? {} : JSON.parse(response.body)
end

apply = ARGV.include?('--apply')
definitions = JSON.parse(File.read(DEFINITIONS))
achievements = definitions.fetch('achievements')
@token = token

app = asc(:get, '/v1/apps', query: { 'filter[bundleId]' => BUNDLE, 'limit' => '2' }).fetch('data')
abort "::error::Nessuna app con Bundle ID #{BUNDLE} accessibile alla chiave." if app.empty?
app_id = app.first.fetch('id')

detail = begin
  asc(:get, "/v1/apps/#{app_id}/gameCenterDetail").fetch('data')
rescue RuntimeError => e
  abort "::error::Game Center non è attivo per l'app (#{e.message}). Attivarlo in App Store Connect e rilanciare."
end
detail_id = detail.fetch('id')

existing = asc(:get, "/v1/gameCenterDetails/#{detail_id}/gameCenterAchievements", query: { 'limit' => '200' })
             .fetch('data').to_h { |a| [a.fetch('attributes').fetch('vendorIdentifier'), a.fetch('id')] }
missing = achievements.reject { |a| existing.key?(a.fetch('id')) }

puts "Game Center detail #{detail_id}: #{existing.size} traguardi già presenti, #{missing.size} da creare."
puts "Punti totali: #{achievements.sum { |a| a.fetch('points') }} (limite Apple 1000)."
missing.each { |a| puts "  + #{a.fetch('id')} · #{a.fetch('names').fetch('en')} · #{a.fetch('points')} pt" }
unless apply
  puts 'Prova (nessuna modifica). Rilanciare con --apply per creare.'
  exit 0
end

created = 0
missing.each do |a|
  id = a.fetch('id')
  response = asc(:post, '/v1/gameCenterAchievements', body: {
    data: {
      type: 'gameCenterAchievements',
      attributes: { vendorIdentifier: id, referenceName: a.fetch('names').fetch('en'), points: a.fetch('points'),
                    showBeforeEarned: true, repeatable: false },
      relationships: { gameCenterDetail: { data: { type: 'gameCenterDetails', id: detail_id } } }
    }
  })
  achievement_id = response.fetch('data').fetch('id')
  a.fetch('names').each do |lang, name|
    next unless LOCALES[lang]
    description = a.fetch('descriptions').fetch(lang, a.fetch('descriptions').fetch('en'))
    asc(:post, '/v1/gameCenterAchievementLocalizations', body: {
      data: {
        type: 'gameCenterAchievementLocalizations',
        attributes: { locale: LOCALES[lang], name: name, beforeEarnedDescription: description, afterEarnedDescription: description },
        relationships: { gameCenterAchievement: { data: { type: 'gameCenterAchievements', id: achievement_id } } }
      }
    })
  end
  created += 1
  puts "creato #{id}"
end
puts "Fatto: #{created} traguardi creati. Le immagini e l'invio in revisione restano da fare in App Store Connect."
