# frozen_string_literal: true

AssetMetadataMock = Struct.new(:script_path, :source_map_path, :cdn_url)
HttpResponseMock = Struct.new(:body, :code, :success?)
ExecutionExceptionMock = Class.new(StandardError)
