module ParrotTn
  # Add some secure methods to read and write files
  module SecureFile
    # Load the file and convert it to yaml object. No exception is thrown when an error occurs
    #
    # @param [String] filename of the file to load
    def secure_load_yml_file(filename)
      begin
        secure_load_yml_file!(filename)
      rescue
        {}
      end
    end

    # Load the file and convert it to yaml object. No exception is thrown when an error occurs
    #
    # @param [String] filename of the file to save
    # @param [Object] content is a yaml object
    def secure_save_yml_file(filename, content)
      begin
        secure_save_yml_file!(filename, content)
      end
    end

    # Load the file and convert it to yaml object. Exception is thrown when an error occurs
    #
    # @param [String] filename of the file to load
    def secure_load_yml_file!(filename)
      begin
        file = File.open(filename )
        yp = YAML::load_documents( file )
      rescue
        raise "Error reading file : #{filename}"
      end
    end

    # save the file and convert the content to yaml string. Exception is thrown when an error occurs
    #
    # @param [String] filename of the file to save
    # @param [Object] content is a yaml object
    def secure_save_yml_file!(filename, content)
      begin
        File.open(filename, "w") do |f|
          f.puts content.to_yaml
        end
      rescue
        raise "Error writting file : #{filename}"
      end
    end
  end
end
