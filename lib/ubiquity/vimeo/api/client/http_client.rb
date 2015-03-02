require 'json'
require 'net/https'


module Ubiquity

  module Vimeo

    class API

      class Client

        class HTTPClient

          attr_accessor :logger, :http, :http_host_address, :http_host_port, :base_uri
          attr_accessor :client_id, :client_secret, :access_token

          attr_accessor :default_request_headers,
                        :authorization_header_key

          attr_reader   :authorization_header_value

          attr_accessor :log_request_body, :log_response_body, :log_pretty_print_body

          attr_accessor :request, :response

          DEFAULT_HTTP_HOST_ADDRESS = 'api.vimeo.com'
          DEFAULT_HTTP_HOST_PORT = 443

          DEFAULT_BASE_PATH = '/'

          DEFAULT_HEADER_CONTENT_TYPE = 'application/json; charset=utf-8'
          DEFAULT_HEADER_ACCEPTS = 'application/vnd.vimeo.*+json; version=3.2'

          DEFAULT_USER_AGENT = "Ubiquity-Vimeo Ruby #{defined?(Ubiquity::Vimeo::Version) ? Ubiquity::Vimeo::Version : ''}"

          def initialize(args = { })
            args = args.dup
            initialize_logger(args)
            initialize_http(args)

            logger.debug { "#{self.class.name}::#{__method__} Arguments: #{args.inspect}" }

            @client_id = args[:client_id]
            @client_secret = args[:client_secret]
            @access_token = args[:access_token]

            @base_uri = args[:base_uri] || "http#{http.use_ssl? ? 's' : ''}://#{http.address}:#{http.port}"
            @default_base_path = args[:default_base_path] || DEFAULT_BASE_PATH

            # @user_agent_default = "#{@hostname}:#{@username} Ruby SDK Version #{Vimeo::VERSION}"

            @authorization_header_key ||= 'Authorization' #CaseSensitiveHeaderKey.new('Authorization')

            content_type = args[:content_type_header] ||= DEFAULT_HEADER_CONTENT_TYPE
            accepts = args[:accepts_header] ||= args[:accept_header] || DEFAULT_HEADER_ACCEPTS

            @default_request_headers = {
                'Content-Type' => content_type,
                'Accept' => accepts,
                authorization_header_key => authorization_header_value,
            }

            @log_request_body = args.fetch(:log_request_body, true)
            @log_response_body = args.fetch(:log_response_body, true)
            @log_pretty_print_body = args.fetch(:log_pretty_print_body, true)

            @parse_response = args.fetch(:parse_response, true)
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

          def initialize_http(args = { })
            @http_host_address = args[:http_host_address] ||= DEFAULT_HTTP_HOST_ADDRESS
            @http_host_port = args[:http_host_port] ||= DEFAULT_HTTP_HOST_PORT
            @http = Net::HTTP.new(http_host_address, http_host_port)
            http.use_ssl = true

            http
          end

          def authorization_header_value
            @authorization_header_value ||= begin
              if access_token
                %(Bearer #{access_token})
              else
                %(Basic #{["#{client_id}:#{client_secret}"].pack('m').delete("\r\n")})
              end
            end
          end

          # Formats a HTTPRequest or HTTPResponse body for log output.
          # @param [HTTPRequest|HTTPResponse] obj
          # @return [String]
          def format_body_for_log_output(obj)
            if obj.content_type == 'application/json'
              if @log_pretty_print_body
                _body = obj.body
                output = JSON.pretty_generate(JSON.parse(_body)) rescue _body
                return output
              else
                return obj.body
              end
            else
              return obj.body.inspect
            end
          end

          # @param [HTTPRequest] request
          def send_request(request)
            @response_parsed = nil
            @request = request
            logger.debug { %(REQUEST: #{request.method} http#{http.use_ssl? ? 's' : ''}://#{http.address}:#{http.port}#{request.path} HEADERS: #{request.to_hash.inspect} #{log_request_body and request.request_body_permitted? ? "\n-- BODY BEGIN --\n#{format_body_for_log_output(request)}\n-- BODY END --" : ''}) }

            @response = http.request(request)
            logger.debug { %(RESPONSE: #{response.inspect} HEADERS: #{response.to_hash.inspect} #{log_response_body and response.respond_to?(:body) ? "\n-- BODY BEGIN --\n#{format_body_for_log_output(response)}\n-- BODY END--" : ''}) }
            #logger.debug { "Parse Response? #{@parse_response}" }
            @parse_response ? response_parsed : response.body
          end

          def response_parsed
            @response_parsed ||= begin
              logger.debug { "Parsing Response. #{response.body.inspect}" }

              if response.content_type.end_with?('json')
                JSON.parse(response.body) rescue response
              else
                response.body
              end

              # case response.content_type
              #   when 'application/json'
              #     JSON.parse(response.body) rescue response
              #   else
              #     if response.content_type.start_with?('application/vnd.vimeo') and response.content_type.end_with?('+json')
              #       JSON.parse(response.body) rescue response
              #     else
              #       response.body
              #     end
              # end
            end
          end

          # @param [String] path
          # @param [Hash|String|Nil] query
          # @return [URI]
          def build_uri(path = '', query = nil)
            _query = query.is_a?(Hash) ? query.map { |k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.respond_to?(:to_s) ? v.to_s : v)}" }.join('&') : query
            _path = "#{path}#{_query and _query.respond_to?(:empty?) and !_query.empty? ? "?#{_query}" : ''}"
            URI.parse(File.join(base_uri, _path))
          end

          # @param [Symbol, String, HTTPRequest] method (:get)
          # @param [Hash] args
          # @option args [Hash] :headers ({})
          # @option args [String] :path ('')
          # @option args [Hash] :query ({})
          # @option args [Any] :body (nil)
          # @param [Hash] options
          # @option options [Hash] :default_request_headers (@default_request_headers)
          def call_method(method = :get, args = { }, options = { })
            headers = args[:headers] || options[:headers] || { }
            path = args[:path] || ''
            query = args[:query] || options[:query] || { }
            body = args[:body]

            # Allow the default request headers to be overridden
            _default_request_headers = options.fetch(:default_request_headers, default_request_headers)
            _default_request_headers ||= { }
            _headers = _default_request_headers.merge(headers)

            @uri = build_uri(path, query)

            # the defined? call may be more expensive then just allow symbols/strings
            # puts start_time = Time.now; defined?(Net::HTTP::Delete::METHOD); run_time = (end_time = Time.now) - start_time
            # puts start_time = Time.now; defined?(Symbol::METHOD); run_time = (end_time = Time.now) - start_time
            # puts start_time = Time.now; defined?(String::METHOD); run_time = (end_time = Time.now) - start_time
            # puts start_time = Time.now; :delete.to_s.capitalize.to_sym; run_time = (end_time = Time.now) - start_time
            # puts start_time = Time.now; 'delete'.to_s.capitalize.to_sym; run_time = (end_time = Time.now) - start_time
            if defined?(method::METHOD)
              klass = method
            else
              klass_name = method.to_s.capitalize.to_sym
              klass = Net::HTTP.const_get(klass_name)
            end

            request = klass.new(@uri.request_uri, _headers)

            if request.request_body_permitted?
              _body = (body and !body.is_a?(String)) ? JSON.generate(body) : body
              logger.debug { "Processing Body: '#{_body}'" }
              request.body = _body if _body
            end

            send_request(request)
          end

          def delete(path, options = { })
            call_method(Net::HTTP::Delete, { :path => path, :query => options[:query] }, options)
          end

          def get(path, options = { })
            call_method(Net::HTTP::Get, { :path => path, :query => options[:query] }, options)
          end

          def head(path, options = { })
            call_method(Net::HTTP::Head, { :path => path, :query => options[:query] }, options)
          end

          def options(path, options = { })
            call_method(Net::HTTP::Options, { :path => path, :query => options[:query] }, options)
          end

          # Ruby 1.8 does not have Net::HTTP::Patch defined
          unless defined?(Net::HTTP::Patch)
            class Net::HTTP::Patch < Net::HTTPRequest
              METHOD = 'PATCH'
              REQUEST_HAS_BODY = true
              RESPONSE_HAS_BODY = true
            end
          end

          def patch(path, body, options = { })
            call_method(Net::HTTP::Patch, { :path => path, :body => body, :query => options[:query] }, options)
          end

          def put(path, body, options = { })
            call_method(Net::HTTP::Put, { :path => path, :body => body, :query => options[:query] }, options)
          end

          def post(path, body, options = { })
            call_method(Net::HTTP::Put, { :path => path, :body => body, :query => options[:query] }, options)
          end

          # HTTPClient
        end

        # Client
      end

      # API
    end

    # Vimeo
  end

  # Ubiquity
end
