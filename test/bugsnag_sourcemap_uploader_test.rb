# frozen_string_literal: true

require 'test_helper'
require 'bugsnag_sourcemap_uploader/upload_task'

class BugsnagSourcemapUploaderTest < Minitest::Test
  AssetMetadataMock = Struct.new(:script_path, :source_map_path, :cdn_url)
  HttpResponseMock = Struct.new(:body, :code, :success?)
  ExecutionExceptionMock = Class.new(StandardError)

  def setup
    @assets_metadata = [
      AssetMetadataMock.new('/script/alert.min.js', '/sourcemap/alert.js.map', 'https://cdn.com/alert.min.js'),
      AssetMetadataMock.new('/script/popup.min.js', '/sourcemap/popup.js.map', 'https://cdn.com/popup.min.js')
    ]

    @api_key = 'FAKE_API_KEY'
  end

  def test_upload_executes_an_upload_task_per_asset_metadata
    BugsnagSourcemapUploader::UploadTask
      .any_instance
      .expects(:upload)
      .times(2)

    BugsnagSourcemapUploader.upload(assets_metadata: @assets_metadata, bugsnag_api_key: @api_key)
  end

  def test_upload_returns_a_result_object
    successful_result = BugsnagSourcemapUploader::UploadTask::Result.new(
      @assets_metadata.first,
      HttpResponseMock.new('success', 200, true)
    )

    BugsnagSourcemapUploader::UploadTask
      .any_instance
      .expects(:upload)
      .returns(successful_result)
      .times(2)

    result = BugsnagSourcemapUploader.upload(assets_metadata: @assets_metadata, bugsnag_api_key: @api_key)

    assert_instance_of(BugsnagSourcemapUploader::Result, result)
  end

  def test_upload_returns_an_object_that_filters_successful_tasks
    successful_result = BugsnagSourcemapUploader::UploadTask::Result.new(
      @assets_metadata.first,
      HttpResponseMock.new('success', 200, true)
    )

    BugsnagSourcemapUploader::UploadTask
      .any_instance
      .expects(:upload)
      .returns(successful_result)
      .times(2)

    result = BugsnagSourcemapUploader.upload(assets_metadata: @assets_metadata, bugsnag_api_key: @api_key)

    assert_equal(2, result.tasks_results.size)
    assert_equal(2, result.successful_tasks.size)
    assert_empty(result.failed_tasks)
    assert_empty(result.execution_error_tasks)
  end

  def test_upload_returns_an_object_that_filters_failed_tasks
    failed_result = BugsnagSourcemapUploader::UploadTask::Result.new(
      @assets_metadata.first,
      HttpResponseMock.new('failure', 500, false)
    )

    BugsnagSourcemapUploader::UploadTask
      .any_instance
      .expects(:upload)
      .returns(failed_result)
      .times(2)

    result = BugsnagSourcemapUploader.upload(assets_metadata: @assets_metadata, bugsnag_api_key: @api_key)

    assert_equal(2, result.tasks_results.size)
    assert_equal(2, result.failed_tasks.size)
    assert_empty(result.successful_tasks)
    assert_empty(result.execution_error_tasks)
  end

  def test_upload_returns_an_object_that_filters_tasks_with_execution_errors
    failed_result = BugsnagSourcemapUploader::UploadTask::ExecutionErrorResult.new(
      @assets_metadata.first,
      ExecutionExceptionMock.new('execution error')
    )

    BugsnagSourcemapUploader::UploadTask
      .any_instance
      .expects(:upload)
      .returns(failed_result)
      .times(2)

    result = BugsnagSourcemapUploader.upload(assets_metadata: @assets_metadata, bugsnag_api_key: @api_key)

    assert_equal(2, result.tasks_results.size)
    assert_equal(2, result.execution_error_tasks.size)
    assert_equal(2, result.failed_tasks.size)
    assert_empty(result.successful_tasks)
  end
end
