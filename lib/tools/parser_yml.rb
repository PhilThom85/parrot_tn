require 'tools/secure_file.rb'

module ParrotTn
  # Parse a yaml file, translate all available texts and create a new yaml file
  # with the same hierarchy.
  class ParserYml
    include ParrotTn::SecureFile

    # @param [Hash] options has a key :guess which can contain a Guess object, otherwise a new is created passing options.
    def initialize(options = {})
      @guess = options[:guess] || ParrotTn::Guess.new(options)
    end

    # Process the parsing of the file for translation
    #
    # @param [String] file to be parsed
    # @param [Symbol] lgdest is the destination language (the source is defined in the yaml file)
    # @param [Hash] options contains :
    #   - :save_to : [String] the path where to write the resulting yaml file (default current dir)
    def parrotize_yaml(file, lgdest, options = {})
      @lgdest = lgdest
      @file = file
      save_to = options[:save_to] || "result_#{@lgstart}_#{@lgdest}.yaml"

      yp = secure_load_yml_file( @file )

      yp.each do |k|
        klg = k.keys.first
        if klg != @lgdest
          @lgstart = klg
          newyaml = {}
          browse_hash k[klg], newyaml

          @allyaml = { @lgdest => newyaml }
          secure_save_yml_file(save_to, @allyaml)
        end
      end
    end

    private

    def resolvenode(n)
      node = ""
      node = {} if n.is_a? Hash
      node = [] if n.is_a? Array
      rs = browse_hash n, node
      return rs if nil != rs
      node
    end

    # Browse the yaml tree and translate leaves
    # returns translated leaf or the name of the node
    # node
    def browse_hash(h, curyaml)
      result = nil
      if h.is_a? Hash
        h.keys.each do |key|
          curyaml[key] = resolvenode h[key]
        end
      elsif h.is_a? Array
        h.each_index do |i|
          curyaml[i] = resolvenode h[i]
        end
      elsif h.is_a? String
        result = ""
        if not h.empty?
          result = @guess.translation h, @lgstart, @lgdest
        end
      else
        result = h
      end
      result
    end
  end
end
