# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module GithubLfsS3
  # Sinatra application 
  class Application < Sinatra::Base
    configure do
      enable :logging
      set :auth, ->(*_) { true }
      set :expires_in, 86_400

      set :bucket, nil

      set :download, (lambda do |oid|
        settings.bucket.object(oid).public_url
      end)
      set :upload, (lambda do |oid|
        settings.bucket.object(oid).presigned_url(
          :put,
          acl: 'public-read',
          expires_in: settings.expires_in
        )
      end)
    end

    helpers do
      def authorized?
        @auth ||= Rack::Auth::Basic::Request.new(request.env)
        return false unless
          @auth.provided? &&
          @auth.basic? &&
          @auth.credentials
        settings.auth(*@auth.credentials)
      end

      def json_error(code, msg)
        halt code, { message: msg }.to_json
      end
    end

    get '/' do
      "Github LFS S3 v#{GithubLfsS3::VERSION}"
    end

    post '/objects/batch', provides: 'application/vnd.git-lfs+json' do
      data = begin
        JSON.parse(request.body.tap(&:rewind).read)
      rescue JSON::ParserError
        json_error 422, 'Invalid JSON request'
      end

      op = data['operation']
      json_error 422, 'Invalid operation' unless %w[download upload].include?(op)
      json_error 401, 'Invalid credentials' if op == 'upload' && !authorized?
      data_objects = data['objects']
      json_error 422, 'Invalid objects' unless data_objects.is_a?(Array)
      objects = data_objects.map do |object|
        object = object.slice('oid', 'size')
        oid, size = object.values
        unless size >= 0 &&
               oid =~ /^[0-9a-f]{64}$/
          next object.merge(
            error: { code: 422, message: 'Validation error' }
          )
        end
        href = op == 'download' ?
          settings.download(oid) :
          settings.upload(oid)

        object.merge(
          authenticated: true,
          actions: {
            op => {
              href: href,
              expires_in: settings.expires_in
            }
          }
        )
      end
      {
        transfer: 'basic',
        objects: objects
      }.to_json
    end
  end
end
