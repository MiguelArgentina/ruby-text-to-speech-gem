require_relative 'tucu/services/api_client'

module Tucu
  ##
  # This class provides methods to convert speech to text using OpenAI's API.
  #
  # Example:
  #
  #   converter = Tucu::SpeechToText.new('<YOUR_API_KEY>')
  #   text = converter.write_down('path_to_audio_file.mp3')
  #
  class SpeechToText
    # List of supported audio extensions
    SUPPORTED_EXTENSIONS = %w[mp3 wav opus ogg].freeze

    ##
    # Initializes the SpeechToText service with the given API key.
    #
    # +openai_api_key+:: The API key for OpenAI.
    #
    # Raises +ApiKeyNotProvided+ error if the API key is missing or blank.
    #
    def initialize(openai_api_key)
      raise ApiKeyNotProvided.new("An OpenAi API_KEY must be provided") unless openai_api_key && !openai_api_key.strip.empty?
      @api_client = APIClient.new(openai_api_key)
    end

    ##
    # Transcribes the provided audio file to text.
    #
    # +audio_file_path+:: The path to the audio file to be transcribed.
    # +extension+:: The file extension/type of the audio file. Default is 'mp3'.
    #
    # Returns the transcribed text.
    #
    def write_down(audio_file_path, extension='mp3')
      if extension == 'opus'
        audio_file_path = convert_opus_to_mp3(input_file, extension)
      end
      @api_client.post(audio_file_path, content_type_for(extension))
    end

    def convert_opus_to_mp3(input_file, file_extension)
      output_file = File.join(Rails.root, "public", "audio", "#{File.basename(input_file, File.extname(input_file))}.#{file_extension}")
      command = "ffmpeg -i #{input_file} -c:a libmp3lame #{output_file}"
      system(command)
      output_file
    end



    ##
    # Returns a human-friendly string listing the supported audio formats.
    #
    # Examples:
    #
    #   Tucu::SpeechToText.supported_formats  #=> "Supported formats: mp3, wav, ogg, flac."
    #
    # Returns:
    # A String describing the supported audio formats.
    #
    def supported_formats
      "Currently, the supported formats are: #{Tucu::ArrayUtils.to_sentence(SUPPORTED_EXTENSIONS)}. We are working on increasing this list"
    end

    private

    ##
    # Determines the MIME content type for a given file extension.
    #
    # +extension+:: The file extension/type.
    #
    # Returns the MIME content type.
    #
    # Raises an error if the provided extension is not supported.
    #
    def content_type_for(extension)
      if SUPPORTED_EXTENSIONS.include?(extension.downcase)
        "audio/#{extension.downcase}"
      else
        raise "Unsupported audio format: #{extension}"
      end
    end
  end

  ##
  # Custom error class for handling cases where an API key is not provided.
  #
  class ApiKeyNotProvided < StandardError; end
end
