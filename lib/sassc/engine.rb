require_relative 'lib'

require_relative 'engine/color'
require_relative 'engine/list'
require_relative 'engine/number'

module SassC
  class Engine

    #  Initializes the SassC engine.
    #
    def initialize(input, options = {})
      @input = input
      @options = options
      @custom_functions = {}
    end

    #  Assigns custom functions to be exposed to Sass.
    #
    def custom_function(signature, &block)
      @custom_functions[signature.to_s] = block
    end
    
    #  Proccesses the passed sass string.
    #
    def render
      sass_context_options = {
        output_style: @options[:output_style] || "nested", 
        source_comments: @options[:source_comments] || "none", 
        image_path: @options[:image_path] || "images",
        include_paths: (@options[:load_paths] || []).map { |path| path.to_s + "/" }.join(File::PATH_SEPARATOR),
        precision: @options[:precision] || 5
      }

      ctx = SassC::Lib::Context.create(@input, sass_context_options)

      unless @custom_functions.empty?
        ctx.set_custom_functions @custom_functions
      end

      success = SassC::Lib.sass_compile(ctx)

      unless ctx[:error_status] == 0
        raise Exception.new(ctx[:error_message].read_string)
      end

      #  Returns the result as string
      ctx[:output_string].read_string
    ensure
      ctx && ctx.free
    end
  end
end
