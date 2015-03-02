require 'ubiquity/vimeo/api/client'

module Ubiquity

  module Vimeo

    class API

      class Utilities < Client

        # @see https://developer.vimeo.com/api/upload
        def video_upload_extended(args = { }, options = { })
          file_path = args[:file_path]
          file_content_type = args[:file_content_type] || args[:content_type]
          file_size = File.size?(file_path)

          # Check Users Quota
          user = me || { }

          # Generate an upload ticket
          upload_quota = user['upload_quota'] || { }
          bytes_free = (upload_quota['free'] || 0)

          raise "File Size Exceeds Quota Free Bytes. #{upload_quota}" unless file_size <= bytes_free



        end


        # Utilities
      end

      # API
    end

    # Vimeo
  end

  # Ubiquity
end
