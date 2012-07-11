require 'active_support/core_ext'
require 'yaml'
require 'google/google_translate'
require 'tools/secure_file.rb'

# Parrot Translation utility
module ParrotTn
  # Object which manages dictionnaries and connexion to google translation
  class Guess
    #@!attribute [rw]
    # List of loaded dictionnaries
    attr_accessor :dicts

    include ParrotTn::SecureFile

    # Initialize the object with settings that allow to use or not
    # google, load a configuration files or set strict result.
    #
    # @param [Hash] options contains keys:
    #   - :google : true/(false), if true use google translator by default
    #   - :strict : true/(false), if true does not return prefix "NT -" into result string
    #   - :dicts  : Hash that contains the list of file dictionnaries
    #   - :load   : String path to a config file
    #   - :user_agent   : String/false used by encoder, if false there's no conversion
    def initialize(options = {})
      @dicts = {}
      @google, @strict  = [ false, false ]
      @data = {}

      reset_options_with options
    end

    # Process the translation of the text from language src to language dst
    #
    # @param [String] text to translate
    # @param [Symbol] src language
    # @param [Symbol] dst language
    # @return [String] the translated text
    def translation(text, src, dst)
      diconame = "#{src}_#{dst}".to_sym
      dico = @dicts[diconame]
      if dico.is_a? String
        dico = [ dico ]
      end
      if @data[diconame].nil? && dico
        dico.each do |name|
          dico_name_ext = "#{src}_#{dst}_dict_#{name}"
          data = load_dictionnary(dico_name_ext).symbolize_keys
          if @data[diconame].nil?
            @data[diconame] = data[diconame]
          else
            @data[diconame].merge! data[diconame]
          end
        end
      end
      tn = @data[diconame][text] if @data[diconame]
      if tn.nil? && google?
        tn = @tr.translate :text => text, :from => src, :to => dst
      end
      if tn.nil? || tn.empty? || tn == text
        tn = text
        unless @strict
          tn = "NT - #{text}"
        end
      end
      tn
    end

    # @return [Boolean] if google should be used or not
    def google?
      @google
    end

    # Reset options used in constructor to new value
    #
    # @param [Hash] options contains options defined in constructor
    def reset_options_with(options)
      set_agent_with(options[:user_agent]) if options.include? :user_agent
      @strict = options[:strict] if options.include? :strict
      if options.include? :load
        options = load_config_file(options[:load]) || {}
        options.symbolize_keys!
      end
      set_google_with(options[:google]) if options.include? :google
      @dicts = options[:dicts].symbolize_keys! if options.include? :dicts
    end


    private

    def set_agent_with(val)
      if @agent != val
        @agent = val
        unless @tr.nil?
          @tr = nil
          set_google_with(@agent)
        end
      end
    end

    def set_google_with(val)
      @google = val
      if val && @tr.nil?
        uri = get_defined_proxy
        @tr = Google::Translate.new do |agent|
          agent.user_agent = @agent unless @agent.nil?
          unless uri.nil?
            agent.set_proxy(uri.host, uri.port, uri.user, uri.password)
          end
        end
      end
    end

    def load_dictionnary(name)
      filename = "#{@dir_dict}/#{name}.yml"
      secure_load_yml_file(filename).first
    end

    def load_config_file(filename)
      @dir_dict = File.dirname(filename)
      secure_load_yml_file(filename).first
    end

    # returns URI object to proxy if defined in environment variable
    def get_defined_proxy
      prime_proxy = ENV.select { |k,v| v if k =~ /http_proxy/i }.first
      if prime_proxy.nil?
        prime_proxy = ENV.select { |k,v| v if k =~ /all_proxy/i }.first
      end
      return nil if prime_proxy.nil?

      URI.parse(prime_proxy[1])
    end
  end
end
