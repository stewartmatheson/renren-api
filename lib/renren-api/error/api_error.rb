module RenrenAPI
  module Error
    class APIError < StandardError
      
      def initialize(code, message)
        @code, @message = code, messgae
      end

      def to_s
        "The Renren API has returned an Error:(#{@code} - #{@message})"
      end

    end
  end
end
