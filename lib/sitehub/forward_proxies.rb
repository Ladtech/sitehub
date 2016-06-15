require 'sitehub/constants'
require 'sitehub/nil_proxy'
require 'rack/request'
require 'rack/response'
require 'rack/utils'
require 'em-http'

class SiteHub
  class ForwardProxies

    NIL_PROXY = NilProxy.new

    def call(env)
      source_request = Rack::Request.new(env)

      forward_proxy = mapped_route(path: source_request.path, request: source_request)

      forward_proxy.call(env)
    end

    def init
      forward_proxies.values.each(&:build)
      self
    end

    def <<(route)
      forward_proxies[route.mapped_path] = route
    end

    def mapped_route(path:, request:)
      fwd_proxy_builder = forward_proxies[mapping(path)]
      fwd_proxy_builder ? fwd_proxy_builder.resolve(id: request.cookies[RECORDED_ROUTES_COOKIE], env: request.env) : forward_proxies.default
    end

    def mapping(path)
      forward_proxies.keys.find do |key|
        case key
        when Regexp
          key.match(path)
        else
          path == key
        end
      end
    end

    def forward_proxies
      @forward_proxies ||= begin
       {}.tap do|hash|
         hash.default = NIL_PROXY
       end
      end
    end
  end
end
