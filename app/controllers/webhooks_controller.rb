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
        process_message(message_text: messaging[:message][:text], sender_id: messaging[:sender][:id])
      end
    end

    render json: nil, status: :ok
  end

  private
    def process_message(message_text:, sender_id:)
      conn = Faraday.new(:url => 'https://graph.facebook.com') do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      message = {
        recipient: {
          id: sender_id
        },
        message: {
          text: message_text
        }
      }

      response = conn.post do |req|
        req.url '/v2.6/me/messages'
        req.headers['Content-Type'] = 'application/json'
        req.params[:access_token] = ENV['PAGE_ACCESS_TOKEN']
        req.body = message.to_json
      end
      # uri: 'https://graph.facebook.com/v2.6/me/messages',
      # qs: { access_token: PAGE_ACCESS_TOKEN },
      # method: 'POST',
      # json: messageData
      Rails.logger.debug response.inspect

      response
    end

    # def permitted_post_params
    #   # params.require(:webhook).permit(:object, :entry => [])
    #   params.permit(:object, entry: [:id, ])
    # end

end
