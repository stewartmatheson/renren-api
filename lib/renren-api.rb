require 'renren-api/authentication'
require 'renren-api/http_adapter'
require 'renren-api/signature_calculator'

module RenrenAPI
  BASE_URL = "http://api.renren.com/restserver.do"
  VERSION = [0, 4]

  def self.version
    VERSION * "."
  end
end
