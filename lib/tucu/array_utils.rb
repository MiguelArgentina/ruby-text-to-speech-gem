module Tucu
  module ArrayUtils
    def self.to_sentence(array, options = {})
      default_connectors = {
        words_connector: ", ",
        two_words_connector: " and ",
        last_word_connector: ", and "
      }

      options = default_connectors.merge(options)

      case array.length
      when 0
        ""
      when 1
        array[0].to_s
      when 2
        "#{array[0]}#{options[:two_words_connector]}#{array[1]}"
      else
        "#{array[0...-1].join(options[:words_connector])}#{options[:last_word_connector]}#{array[-1]}"
      end
    end
  end
end
