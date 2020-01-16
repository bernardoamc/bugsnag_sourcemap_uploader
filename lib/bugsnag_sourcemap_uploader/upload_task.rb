# frozen_string_literal: true

require 'httparty'

module BugsnagSourcemapUploader
  # The unit of work to send a sourcemap with its associated minified javascript
  # file to Bugsnag.
  class UploadTask
    UPLOAD_URL = 'https://upload.bugsnag.com/' # Bugsnag upload URL

    def initialize(asset_metadata:, bugsnag_api_key:)
      @asset_metadata = asset_metadata
      @bugsnag_api_key = bugsnag_api_key
    end

    def upload(http_options: {})
      body_payload = {
        'apiKey' => @bugsnag_api_key,
        'minifiedUrl' => @asset_metadata.cdn_url,
        'sourceMap' => source_map_contents,
        'minifiedFile' => script_contents,
        'overwrite' => true
      }

      payload = http_options.merge(body: body_payload)

      Response.new(
        asset_metadata,
        HttpParty.post(UPLOAD_URL, payload)
      )
    rescue StandardError => e
      ExecutionError.new(asset_metadata, e)
    end

    private

    def source_map_contents
      File.open(@asset_metadata.source_map_path)
    end

    def script_contents
      File.open(@asset_metadata.script_path)
    end

    # Represents the response of the UploadTask#upload method.
    class Response
      HTTP_TIMEOUT_CODE = 408 # HTTP status code for timeouts
      HTTP_TOO_MANY_REQUESTS_CODE = 429 # HTTP status code for too many requests

      attr_reader :asset_metadata

      def initialize(asset_metadata, http_response)
        @asset_metadata = asset_metadata
        @http_response = http_response
      end

      def reason
        @http_response.body
      end

      def status_code
        @http_response.code
      end

      def success?
        @http_response.success?
      end

      def failure?
        !success?
      end

      def execution_error?
        false
      end

      def retryable?
        status_code < 400 ||
          status_code > 499 ||
          [HTTP_TIMEOUT_CODE, HTTP_TOO_MANY_REQUESTS_CODE].include?(status_code)
      end
    end

    # Represents the response of the UploadTask#upload method when an exception occurred.
    class ExecutionError
      attr_reader :asset_metadata, :exception

      def initialize(asset_metadata, exception)
        @asset_metadata = asset_metadata
        @exception = exception
      end

      def reason
        @exception.message
      end

      def success?
        false
      end

      def failure?
        true
      end

      def execution_error?
        true
      end

      def retryable?
        true
      end
    end
  end
end
