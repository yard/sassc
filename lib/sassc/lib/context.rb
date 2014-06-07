require_relative 'sass_options'

module SassC::Lib
  class Context < FFI::Struct
    
    # struct sass_context {
    #   const char* input_path;
    #   const char* output_path;
    #   const char* source_string;
    #   char* output_string;
    #   char* source_map_string;
    #   const char* source_map_file;
    #   struct sass_options options;
    #   int error_status;
    #   char* error_message;
    #   struct Sass_C_Function_Descriptor* c_functions;
    #   int num_c_functions;
    #   char** included_files;
    #   int num_included_files;
    # };



    # struct sass_context {
    #   const char* source_string;
    #   char* output_string;
    #   struct sass_options options;
    #   int error_status;
    #   char* error_message;
    #   struct Sass_C_Function_Data* c_functions;
    #   int num_c_functions;
    #   char** included_files;
    #   int num_included_files;
    # };

    layout :input_path,         :pointer,
           :output_path,        :pointer,
           :source_string,      :pointer,
           :output_string,      :pointer,
           :source_map_string,  :pointer,
           :source_map_file,    :pointer,
           :options,            SassOptions,
           :error_status,       :int32,
           :error_message,      :pointer,
           :c_functions,        :pointer,
           :num_c_functions,    :int32,
           :included_files,     :pointer,
           :num_included_files, :int32


    #  Creates SASSC context using the input string and options provided.
    #
    def self.create(input_string, sass_options = {})
      ptr = SassC::Lib.sass_new_context
      
      SassC::Lib::Context.new(ptr).tap do |ctx|
        ctx[:source_string]   = FFI::MemoryPointer.from_string( input_string )
        ctx[:options]         = SassC::Lib::SassOptions.create( sass_options )
        ctx[:num_c_functions] = 0
        ctx[:c_functions]     = nil

        return ctx
      end
    end

    #  Sets the custom functions array to be exposes to sass.
    #  
    #  The functions are supposed to be Ruby blocks, received 1 argument and returning 1 result.
    #
    def set_custom_functions(input_funcs)
      funcs_ptr = FFI::MemoryPointer.new(SassC::Lib::SassCFunctionDescriptor, input_funcs.count + 1)

      input_funcs.each.with_index do |(signature, block), i|
        fn = SassC::Lib::SassCFunctionDescriptor.new(funcs_ptr + i * SassC::Lib::SassCFunctionDescriptor.size)

        fn[:signature] = FFI::MemoryPointer.from_string(signature)
        fn[:function] = FFI::Function.new(SassC::Lib::SassValue.by_value, [SassC::Lib::SassValue.by_value, :pointer]) do |arg, cookie|
          ruby_arg    = arg.to_ruby 
          ruby_result = block.call(ruby_arg)
          SassC::Lib::SassValue.new.from_ruby(ruby_result) 
        end
      end

      self[:c_functions]      = funcs_ptr
      self[:num_c_functions]  = input_funcs.size 
    end

    #  Frees the allocated memory.
    #
    def free
      SassC::Lib.sass_free_context(self)
    end

  end
end