# frozen_string_literal: true

require 'bugsnag_sourcemap_uploader/version'
require 'bugsnag_sourcemap_uploader/upload_task'
require 'concurrent'

##
# BugsnagSourcemapUploader is a library to enable parallel sourcemap uploads to Bugsnag.
module BugsnagSourcemapUploader
  TASK_TIMEOUT_IN_SECONDS = 10 # Task timeout in seconds

  # Upload sourcemaps to Bugsnag.
  #
  # @param assets_metadata [Array] object
  #   Each item in this Array must be an object that responds to
  #   `#script_path`, `#source_map_path` and `#cdn_url`.
  # @param bugsnag_api_key [String] key
  #   The Bugsnag API key.
  # @param http_options [Hash] HTTP options
  #   Options accepted by HTTParty.
  #   Useful to set headers or logging details.
  #
  # @return [BugsnagSourcemapUploader::Result] The object with the results of our operation.
  def self.upload(assets_metadata:, bugsnag_api_key:, http_options: {})
    pool = Concurrent::ThreadPoolExecutor.new(
      min_threads: 4,
      max_threads: Concurrent.processor_count
    )

    futures = assets_metadata.map do |asset_metadata|
      Concurrent::Future.execute(executor: pool) do
        UploadTask.new(
          asset_metadata: asset_metadata,
          bugsnag_api_key: bugsnag_api_key
        ).run(http_options)
      end
    end

    responses = futures.map do |future|
      future.value(TASK_TIMEOUT_IN_SECONDS)
    end

    Result.new(responses)
  end

  ##
  # Represents the result of the BugsnagSourcemapUploader.upload operation
  class Result
    attr_reader :tasks_results

    def initialize(tasks_results)
      @tasks_results = tasks_results
    end

    # Answers whether every upload task was successful or not.
    #
    # @return [Boolean] value.
    def success?
      @success ||= @tasks_results.all?(&:success?)
    end

    # Answers whether we had failures among upload tasks.
    #
    # @return [Boolean] value.
    def failure?
      !success?
    end

    # Filters upload tasks that were successful.
    #
    # @return [Array] The list of tasks that were succesful.
    def successful_tasks
      @successful_tasks ||= @tasks_results.select(&:success?)
    end

    # Filters upload tasks that failed with HTTP errors. This includes HTTP failures
    # or execution errors.
    #
    # @return [Array] The list of tasks that failed.
    def failed_tasks
      @failed_tasks ||= @tasks_results.select(&:failure?)
    end

    # Filters upload tasks that had execution errors.
    #
    # @return [Array] The list of tasks with execution errors.
    def execution_error_tasks
      @execution_error_tasks ||= failed_tasks.select(&:execution_error?)
    end
  end
end
