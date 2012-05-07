# encoding: UTF-8

require "zlib"
require "json"
require "faraday"
require "faraday_middleware"

module RenrenAPI
  class HTTPAdapter


    def initialize(api_key, secret_key, session_key)
      @api_key, @secret_key, @session_key = api_key, secret_key, session_key
    end

    def get_friends
      params = {
        :api_key => @api_key,
        :method => "friends.getFriends",
        :call_id => current_time_in_milliseconds,
        :v => "1.0",
        :session_key => @session_key
      }
      request(params, :get)
    end

    def get_info(uids, fields)
      params = {
        :api_key => @api_key,
        :method => "users.getInfo",
        :call_id => current_time_in_milliseconds,
        :v => "1.0",
        :session_key => @session_key,
        :fields => fields * ",",
        :uids => uids * ","
      }
      request(params, :get)
    end

    def send_notification(receiver_ids, notification)
      params = {
        :api_key => @api_key,
        :method => "notifications.send",
        :call_id => current_time_in_milliseconds,
        :v => "1.0",
        :session_key => @session_key,
        :to_ids => receiver_ids * ",",
        :notification => notification
      }
      request(params, :post)
    end

    def set_status(status)
      params = {
        :api_key => @api_key,
        :method => "status.set",
        :call_id => current_time_in_milliseconds,
        :v => "1.0",
        :session_key => @session_key,
        :status => status
      }
      request(params, :post)
    end

    private

    def current_time_in_milliseconds
      "%.3f" % Time.now.to_f
    end

    def request(params, http_method)
      conn = Faraday.new(:url => RenrenAPI::BASE_URL) do |c|
        c.use Faraday::Request::UrlEncoded
        c.use Faraday::Response::Logger
        c.use Faraday::Adapter::NetHttp
        c.use FaradayMiddleware::ParseJson, content_type: 'application/json'
      end

      conn.headers["content-type"] = "application/json;"
      signature_calculator = SignatureCalculator.new(@secret_key)
      params[:sig] = signature_calculator.calculate(params)

      params[:format] = "JSON"
      conn.params = params
      response = conn.send http_method
      raise RenrenAPI::Error::HTTPError.new(response.status) if (400..599).include?(response.status)
      raise RenrenAPI::Error::Adapter.new
      JSON.parse(response.body)
    end

  end
end
