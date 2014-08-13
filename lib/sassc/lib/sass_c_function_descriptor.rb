module SassC::Lib
  class SassCFunctionDescriptor < FFI::Struct
    
    # struct Sass_C_Function_Descriptor {
    #   const char*     signature;
    #   Sass_C_Function function;
    #   void *cookie;
    # };

    layout :signature,  :pointer,
           :function,   :pointer,
           :cookie,     :pointer
  end
end
