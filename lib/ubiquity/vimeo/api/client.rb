require 'ubiquity/vimeo'
require 'ubiquity/vimeo/api/client/http_client'
require 'ubiquity/vimeo/api/client/requests'

module Ubiquity

  module Vimeo

    class API

      class Client

        attr_accessor :logger, :client_id, :access_token, :client_secret, :http_client, :request, :response

        def initialize(args = { })
          initialize_logger(args)
          initialize_http_client(args)

          @client_id = args[:client_id]
          @access_token = args[:access_token]
          @client_secret = args[:secret]

          # @default_headers = args[:default_headers] || begin
          #   _headers = {
          #       'Accept' => DEFAULT_VERSION_STRING,
          #       'User-Agent' => DEFAULT_USER_AGENT
          #   }
          #   if access_token
          #     _headers['Authorization'] = "Bearer #{access_token}"
          #   else
          #     @authorization_header_value ||= auth_header
          #   end
          # end

        end

        def initialize_logger(args = { })
          @logger = args[:logger] ||= Logger.new(args[:log_to] || STDOUT)
          log_level = args[:log_level]
          if log_level
            @logger.level = log_level
            args[:logger] = @logger
          end
          @logger
        end

        def initialize_http_client(args = { })
          # @http_host_address = args[:http_host_address] ||= DEFAULT_HTTP_HOST_ADDRESS
          # @http_host_port = args[:http_host_port] ||= DEFAULT_HTTP_HOST_PORT
          # @http = Net::HTTP.new(http_host_address, http_host_port)
          @http_client = HTTPClient.new(args)
        end
        alias :http :http_client

        def success?
          http_client.response and http_client.response.code and http_client.response.code.start_with?('200')
        end

        # def auth_header
        #   @auth_header ||= %(Basic #{["#{client_id}:#{client_secret}"].pack('m').delete("\r\n")})
        # end

        def process_request(request, options = nil)
          @response = nil
          @request = request
          logger.warn { "Request is Missing Required Arguments: #{request.missing_required_arguments.inspect}" } unless request.missing_required_arguments.empty?
          request.client = self unless request.client
          options ||= request.options

          return (options.fetch(:return_request, true) ? request : nil) unless options.fetch(:execute_request, true)

          #@response = http_client.call_method(request.http_method, { :path => request.path, :query => request.query, :body => request.body }, options)
          @response = request.execute
        end

        def process_request_using_class(request_class, args, options = { })
          @response = nil
          @request = request_class.new(args, options)
          process_request(request, options)
        end

        # @see https://developer.vimeo.com/api/endpoints/me#
        def me(args = { }, options = { })
          # http.get('me')
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'me'
            }
          )
          process_request(_request, options)
        end

        # Begin the video upload process
        # @see https://developer.vimeo.com/api/endpoints/users#/{user_id}/videos
        def user_video_create(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'users/#{path_arguments[:user_id]}/videos',
              :http_method => :post,
              :parameters => [
                { :name => :user_id, :send_in => :path },
                { :name => :type, :send_in => :body },
                { :name => :redirect_url, :send_in => :body },
                { :name => :link, :send_in => :body },
                { :name => :upgrade_to_1080, :send_in => :body }
              ]
            }.merge(options)
          )

          process_request(_request, options)
        end

        # @see https://developer.vimeo.com/api/endpoints/users#/{user_id}/videos
        def video_delete(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'videos/#{path_arguments[:video_id]}',
              :http_method => :delete,
              :http_success_code => 204,

              :parameters => [
                { :name => :video_id, :send_in => :path },
              ]
            }.merge(options)
          )

          process_request(_request, options)
        end

        # @see https://developer.vimeo.com/api/endpoints/videos#/{video_id}
        def video_edit(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'videos/#{path_arguments[:video_id]}',
              :http_method => :patch,
              :http_success_code => 204,
              :default_parameter_send_in_value => :body,

              :parameters => [
                { :name => :video_id, :aliases => [ :id ], :send_in => :path },
                { :name => :name, :send_in => :body },
                { :name => :description, :send_in => :body },
                :license,
                'privacy.view',
                :password,
                'privacy.embed',
                :review_link,
                :locale,
                'embed.buttons.like',
                'embed.buttons.watchlater',
                'embed.buttons.share',
                'embed.buttons.embed',
                'embed.buttons.hd',
                'embed.buttons.fullscreen',
                'embed.buttons.scaling',
                'embed.logos.vimeo',
                'embed.logos.custom.active',
                'embed.logos.custom.sticky',
                'embed.logos.custom.link',
                'embed.playbar',
                'embed.volume',
                'embed.color',
                'embed.title.owner',
                'embed.title.portrait',
                'embed.title.name'
              ]
            }.merge(options)
          )

          process_request(_request, options)
        end

        def video_get(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'videos/#{path_arguments[:video_id]}',
              :parameters => [
                { :name => :video_id, :send_in => :path }
              ]
            }
          )
          process_request(_request, options)
        end

        def video_upload(args = { }, options = { })
          # BOUNDARY = "AaB03xZZZZZZ11322321111XSDW"
          # uri = URI.parse("http://localhost/dropbox/")
          # file = "/tmp/KEYS.txt"
          # http = Net::HTTP.new(uri.host, uri.port)
          # request = Net::HTTP::Put.new(uri.request_uri)
          # request.body_stream=File.open(file)
          # request["Content-Type"] = "multipart/form-data"
          # request.add_field('Content-Length', File.size(file))
          # request.add_field('session', BOUNDARY)
          # response=http.request(request)
          # puts "Request Headers: #{request.to_hash.inspect}"
          # puts "Sending PUT #{uri.request_uri} to #{uri.host}:#{uri.port}"
          # puts "Response #{response.code} #{response.message}"
          # puts "#{response.body}"
          # puts "Headers: #{response.to_hash.inspect}"
          _request = BaseRequest.new(
            args,
            {
              :http_path => 'upload',
              :parameters => [
                { :name => :ticket_id, :send_in => :query }
              ]
            }.merge(options)
          )


          # http_request = Net::HTTP::Post.new()
        end

        def video_upload_ticket_create(args = { }, options = { })
          _request = BaseRequest.new(
            args,
            {
              :http_path => 'me/videos',
              :http_method => :post,

              :parameters => [
                { :name => :type, :send_in => :body },
                { :name => :redirect_url, :send_in => :body },
                { :name => :upgrade_to_1080, :send_in => :body },
              ]
            }.merge(options)
          )
          process_request(_request)
        end


        # Client
      end

      # API
    end

    # Vimeo
  end

  # Ubiquity
end
