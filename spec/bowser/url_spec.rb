require 'bowser/url'

module Bowser
  RSpec.describe URL do
    context 'when all fields are provided' do
      let(:url) { URL.new('https://me:secret@example.com:8080/path?foo=bar&foo=baz&omg=lol#zomghash') }

      it 'parses the scheme' do
        expect(url.scheme).to eq 'https'
      end

      it 'parses the username' do
        expect(url.username).to eq 'me'
      end

      it 'parses the password' do
        expect(url.password).to eq 'secret'
      end

      it 'parses the host' do
        expect(url.host).to eq 'example.com'
      end

      it 'parses the port' do
        expect(url.port).to eq 8080
      end

      it 'parses the path' do
        expect(url.path).to eq '/path'
      end

      it 'parses the query string' do
        expect(url.search).to eq '?foo=bar&foo=baz&omg=lol'
        expect(url.query[:foo]).to eq %w(bar baz)
        expect(url.query[:omg]).to eq 'lol'
      end

      it 'parses the hash' do
        expect(url.hash).to eq '#zomghash'
      end
    end

    context 'when only the scheme, host, and path are present' do
      let(:url) { URL.new('https://github.com/clearwater-rb/clearwater') }

      it 'parses the scheme' do
        expect(url.scheme).to eq 'https'
      end

      it 'parses the host' do
        expect(url.host).to eq 'github.com'
      end

      it 'parses the path' do
        expect(url.path).to eq '/clearwater-rb/clearwater'
      end
    end
  end
end
