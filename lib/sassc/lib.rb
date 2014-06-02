require 'ffi'
require 'rbconfig'

require_relative 'lib/context'
require_relative 'lib/context'
require_relative 'lib/sass_value'
require_relative 'lib/sass_c_function_descriptor'

module SassC
  
  #  Represents the exact wrapper around libsass
  #
  module Lib
    extend FFI::Library

    ffi_lib File.join(File.dirname(__FILE__), "libsass.#{ RbConfig::CONFIG['DLEXT'] }")

    attach_function :sass_new_context,          [], :pointer
    attach_function :sass_new_file_context,     [], :pointer
    attach_function :sass_new_folder_context,   [], :pointer
    
    attach_function :sass_free_context,         [:pointer], :void
    attach_function :sass_free_file_context,    [:pointer], :void
    attach_function :sass_free_folder_context,  [:pointer], :void
    
    attach_function :sass_compile,              [:pointer], :int32
    attach_function :sass_compile_file,         [:pointer], :int32

  end

end