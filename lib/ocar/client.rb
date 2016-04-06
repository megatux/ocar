require 'json'
require 'typhoeus'

module Ocar

  extend self

  TYPES = ["cartas", "paquetes", "dni", "partidas" ]
  $hydra = Typhoeus::Hydra.new

  def get_package track_id
    requests = setup_request track_id
    run_request
    get_response requests
  end

  private
  def setup_request track_id
    requests = TYPES.map { |type|
      # e.g. http://www.oca.com.ar/?q=package-locator&type=paquetes&number=1808200000001055400
      request = Typhoeus::Request.new("http://www.oca.com.ar",
        method: :get,
        params: { q: "package-locator",
        type: type,
        number: track_id },
        headers: { Accept: "application/json, text/javascript, */*; q=0.01" }
      )
      $hydra.queue(request)
      request
    }
  end

  def run_request
    $hydra.run
  end

  def get_response requests
    results = []
    responses = requests.map do |request|
      parsed = JSON.parse request.response.body
      results << parsed if parsed['success'] == true
    end
    results
  end
end
