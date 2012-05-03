require_relative "signature_calculator"
require "uri"
require "zlib"
require "json"
require "faraday"
require "faraday_middleware"

module RenrenAPI
  class HTTPAdapter

    def initialize(api_key, secret_key, session_key)
      @api_key, @secret_key, @session_key = api_key, secret_key, session_key
      @signature_calculator = SignatureCalculator.new(@secret_key)
    end

    def get_friends
      params = {
        :api_key => @api_key,
        :method => "friends.getFriends",
        :call_id => current_time_in_millisecond,
        :v => "1.0",
        :session_key => @session_key,
        :format => "JSON"
      }
      request(params)
    end

    def get_info(uids, fields)
      params = {
        :api_key => @api_key,
        :method => "users.getInfo",
        :call_id => current_time_in_millisecond,
        :v => "1.0",
        :session_key => @session_key,
        :fields => fields * ",",
        :uids => uids * ",",
        :format => "JSON"
      }
      request(params)
    end

    def send_notification(receiver_ids, notification)
      request(
        :api_key => @api_key,
        :method => "notifications.send",
        :call_id => current_time_in_millisecond,
        :v => "1.0",
        :session_key => @session_key,
        :format => "JSON",
        :to_ids => receiver_ids * ",",
        :notification => notification
      )
    end

    def set_status(status)
      request(
        :api_key => @api_key,
        :method => "status.set",
        :call_id => current_time_in_millisecond,
        :v => "1.0",
        :session_key => @session_key,
        :format => "JSON",
        :status => status
      )
    end

    private

    def current_time_in_millisecond
      "%.3f" % Time.now.to_f
    end

    def request(params)
      conn = Faraday.new(:url => '') do |c|
        c.use Faraday::Request::UrlEncoded
        c.use Faraday::Response::Logger
        c.use Faraday::Adapter::NetHttp
        c.use FaradayMiddleware::ParseJson, content_type: 'application/json'
      end

      conn.headers["Accept-Encoding"] = "gzip"
      params[:sig] = @signature_calculator.calculate(params)

      conn.params = params
      response = conn.post '/restserver.do'
      gzip_reader = Zlib::GzipReader.new(StringIO.new(response.body))
      JSON.parse(gzip_reader.read)
    end

  end
end
