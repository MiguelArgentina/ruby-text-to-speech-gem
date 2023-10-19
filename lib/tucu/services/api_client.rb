require 'faraday'
require 'faraday_middleware'
require 'json'

module Tucu
  ##
  # This class handles interactions with the OpenAI API.
  # It provides methods to send audio files for speech-to-text conversion.
  #
  class APIClient
    # Base URL for OpenAI's API.
    BASE_URL = 'https://api.openai.com/v1/'

    ##
    # Initializes the APIClient with the given API key.
    #
    # +api_key+:: The API key for OpenAI.
    #
    def initialize(api_key)
      @api_key = api_key
      @conn = Faraday.new(url: BASE_URL) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
        faraday.headers['Authorization'] = "Bearer #{@api_key}"
      end
      puts "_" * 80
      puts @conn.inspect
      puts "_" * 80
    end

    ##
    # Sends a POST request to the OpenAI API to transcribe an audio file.
    #
    # +audio_file_path+:: The path to the audio file.
    # +content_type+:: The MIME content type for the audio file.
    #
    # Returns the transcribed text.
    #
    # Raises an error if there are issues with the request, such as an invalid API key.
    #
    def post(audio_file_path, content_type)
      response = @conn.post('audio/transcriptions') do |req|
        req.headers['Content-Type'] = 'multipart/form-data'
        req.body = {
          file: Faraday::UploadIO.new(audio_file_path, content_type),
          model: 'whisper-1'
        }
      end

      handle_response(response)
    end



    private

    ##
    # Handles the response from the OpenAI API.
    #
    # +response+:: The Faraday::Response object.
    #
    # Returns the transcribed text from the API.
    #
    # Raises an error if the response indicates an issue.
    #
    def handle_response(response)
      case response.status
      when 200
        JSON.parse(response.body)
      when 401
        raise 'Invalid API key or unauthorized request!'
        # Add more status code checks if necessary
      else
        raise "API Error: #{response.body}"
      end
    end
  end
end
