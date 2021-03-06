class SiteHub
  class Response < Rack::Response
    attr_reader :status, :headers, :body, :time
    def initialize(body, status, headers)
      super
      @time = Time.now
    end
    alias headers header
  end
end
