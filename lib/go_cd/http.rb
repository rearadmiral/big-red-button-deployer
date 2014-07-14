require 'httparty'

module GoCD

  module Http

      def self.get(url, auth_options)
        r = HTTParty.get(url, basic_auth: auth_options)
        if r.code >= 200 && r.code < 400
          yield r
        else
          puts r.parsed_response
          raise "unexpected HTTP response for GET #{url}: #{r.code}"
        end
      end

      def self.post(url, auth_options)
        r = HTTParty.post(url, basic_auth: auth_options)
        if r.code >= 200 && r.code < 400
          yield r
        elsif r.code == 409
          raise "HTTP 409. Pipeline is probably paused."
        else
          puts r.parsed_response
          raise "unexpected HTTP response for POST #{url}: #{r.code}"
        end
      end

  end

end
