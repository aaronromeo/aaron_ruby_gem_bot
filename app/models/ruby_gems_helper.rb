class RubyGemsHelper
  def self.get_gem_details(gem_name)
    conn = Faraday.new(:url => 'https://rubygems.org') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    response = conn.get "/api/v1/gems/#{gem_name}.json"
    return prep_response(JSON.parse(response.body).with_indifferent_access) if response.status == 200

    {text: "Gem '#{gem_name}' not found"}
  end

  private
    def self.prep_response(response_body)
      {
        attachment: {
          type: "template",
          payload: {
            template_type: "generic",
            elements: [{
              title: response_body.fetch(:name, ''),
              subtitle: response_body.fetch(:info, ''),
              item_url: response_body.fetch(:project_uri, ''),
            }]
          }
        }
      }
    end

end