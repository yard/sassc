module SassC::Lib
  class SassOptions < FFI::Struct
    STYLES = %w(nested expanded compact compressed)
    SOURCE_COMMENTS = %w(none default map)

    # struct sass_options {
    #   int output_style;
    #   int source_comments; // really want a bool, but C doesn't have them
    #   const char* include_paths;
    #   const char* image_path;
    #   int precision;
    # };

    layout :output_style,    :int32,
           :source_comments, :int32,
           :include_paths,   :pointer,
           :image_path,      :pointer,
           :precision,       :int32

    #  Creates sass_options struct to be passed down upon creation of
    #  the context.
    #
    def self.create(options = {})
      options = {
        output_style: "nested", 
        source_comments: "none", 
        image_path: "images",
        include_paths: "",
        precision: 5
      }.merge(options)

      SassOptions.new.tap do |struct|
        struct[:output_style]     = STYLES.index(options[:output_style])
        struct[:source_comments]  = SOURCE_COMMENTS.index(options[:source_comments])
        struct[:include_paths]    = FFI::MemoryPointer.from_string(options[:include_paths])
        struct[:image_path]       = FFI::MemoryPointer.from_string(options[:image_path])
        struct[:precision]        = options[:precision].to_i
      end
    end
  end
end