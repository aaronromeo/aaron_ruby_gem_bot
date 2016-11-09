class WebhooksController < ApplicationController
  def index
    if params['hub.verify_token'] == ENV['VERIFY_TOKEN']
      render json: params['hub.challenge'], status: :ok
    else
      render json: nil, status: :unprocessable_entity
    end
  end

  def create
    if params[:object] != 'page'
      render json: nil, status: :unprocessable_entity
      return
    end

    params[:entry].each do |entry|

      entry[:messaging].each do |messaging|
        sender_id = messaging[:sender][:id]
        process_text_message(message_text: messaging[:message][:text], sender_id: sender_id) if messaging.has_key? :message
        process_postback(payload: messaging[:postback][:payload], sender_id: sender_id) if messaging.has_key? :postback
      end
    end

    render json: nil, status: :ok
  end

  private
    def process_postback(payload:, sender_id:)
      message = case payload
        when 'GETTING_STARTED_BUTTON' then {
            recipient: {
              id: sender_id
            },
            message: create_getting_started_message.to_json
          }
        else nil
      end
      send_api_message message: message if message
    end

    def create_getting_started_message
      {
        attachment: {
          type: "template",
          payload: {
            template_type: "generic",
            elements: [
              {
                title: 'You give us a gem name, we give you info',
                buttons:[
                  {
                    type: "web_url",
                    url: Rails.application.routes.url_helpers.getting_started_buttons_url,
                    title: "Give me some info",
                    webview_height_ratio: "compact"
                  }
                ]
              }
            ]
          }
        }
      }
    end

    def process_text_message(message_text:, sender_id:)
      gem_details = RubyGemsHelper.get_gem_details message_text

      message = {
        recipient: {
          id: sender_id
        },
        message: gem_details
      }

      send_api_message message: message
    end

    def send_api_message(message:)
      conn = Faraday.new(:url => 'https://graph.facebook.com') do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      response = conn.post do |req|
        req.url '/v2.6/me/messages'
        req.headers['Content-Type'] = 'application/json'
        req.params[:access_token] = ENV['PAGE_ACCESS_TOKEN']
        req.body = message.to_json
      end
    end
end
