namespace :messenger do
  desc "Setup a greeting message for new users"
  task set_greeting_message: :environment do
    conn = Faraday.new(:url => 'https://graph.facebook.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    message = {
      "setting_type":"greeting",
      "greeting":{
        "text":"Type in the name of a gem to get information about it."
      }
    }

    response = conn.post do |req|
      req.url 'v2.6/me/thread_settings'
      req.headers['Content-Type'] = 'application/json'
      req.params[:access_token] = ENV['PAGE_ACCESS_TOKEN']
      req.body = message.to_json
    end
  end

  desc "Setup a getting started button for new users"
  task set_getting_started_button: :environment do
    conn = Faraday.new(:url => 'https://graph.facebook.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    message = {
      "setting_type":"call_to_actions",
      "thread_state":"new_thread",
      "call_to_actions":[
        {
          "payload":"GETTING_STARTED_BUTTON"
        }
      ]
    }

    response = conn.post do |req|
      req.url 'v2.6/me/thread_settings'
      req.headers['Content-Type'] = 'application/json'
      req.params[:access_token] = ENV['PAGE_ACCESS_TOKEN']
      req.body = message.to_json
    end
  end

end
