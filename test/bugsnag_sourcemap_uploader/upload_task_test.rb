# frozen_string_literal: true

require 'test_helper'
require 'bugsnag_sourcemap_uploader/upload_task'
require 'mocks'

module BugsnagSourcemapUploader
  class UploadTaskTest < Minitest::Test
    def setup
      @bugsnag_api_key = 'FAKE_API_KEY'
      @asset_metadata = AssetMetadataMock.new(
        '/script/alert.min.js',
        '/sourcemap/alert.js.map',
        'https://cdn.com/alert.min.js'
      )

      @upload_task = UploadTask.new(
        asset_metadata: @asset_metadata,
        bugsnag_api_key: @bugsnag_api_key
      )
    end

    def test_upload_delegates_to_httparty
      @upload_task.expects(:source_map_contents).returns('sourcemap_content').once
      @upload_task.expects(:script_contents).returns('script_content').once

      expected_body = {
        'apiKey' => @bugsnag_api_key,
        'minifiedUrl' => @asset_metadata.cdn_url,
        'sourceMap' => 'sourcemap_content',
        'minifiedFile' => 'script_content',
        'overwrite' => true
      }

      HTTParty
        .expects(:post)
        .with(UploadTask::UPLOAD_URL, body: expected_body)
        .returns(HttpResponseMock.new('success', 200, true))
        .once

      @upload_task.run
    end

    def test_upload_returns_an_object_that_indicates_the_result_of_the_executed_task
      setup_post_expectations(task: @upload_task, response: HttpResponseMock.new('success', 200, true))

      result = @upload_task.run

      assert_equal(true, result.success?)
      assert_equal(false, result.failure?)
      assert_equal(false, result.execution_error?)
      assert_equal('success', result.reason)
      assert_equal(200, result.status_code)
    end

    def test_upload_returns_an_object_that_indicates_if_the_task_is_retryable_or_not
      setup_post_expectations(task: @upload_task, response: HttpResponseMock.new('failure', 500, false))

      result = @upload_task.run
      assert_equal(true, result.retryable?)

      setup_post_expectations(task: @upload_task, response: HttpResponseMock.new('failure', 404, false))

      result = @upload_task.run
      assert_equal(false, result.retryable?)
    end

    def test_upload_returns_an_object_that_flags_an_execution_error
      @upload_task.expects(:source_map_contents).raises(StandardError.new('boom!')).once

      result = @upload_task.run
      assert_equal(true, result.execution_error?)
      assert_equal('boom!', result.reason)
    end

    private

    def setup_post_expectations(task:, response:)
      task.expects(:source_map_contents).returns('sourcemap_content').once
      task.expects(:script_contents).returns('script_content').once
      HTTParty.expects(:post).returns(response).once
    end
  end
end
