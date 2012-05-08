# encoding: UTF-8

require 'renren-api/signature_calculator'
require 'renren-api/authentication'
require 'renren-api/http_adapter'
require 'renren-api/error/http_error'
require 'renren-api/error/api_error'

module RenrenAPI
  BASE_URL = "http://api.renren.com/restserver.do"
  VERSION = [0, 4]

  def self.version
    VERSION * "."
  end
end
