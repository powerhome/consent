# frozen_string_literal: true

module Consent
  class Action # :nodoc:
    attr_reader :key, :label, :options

    def initialize(key, label, subject, options = {})
      @key = key
      @label = label
      @options = options
      @subject = subject
    end

    def views
      @subject.views.slice(*view_keys)
    end

    def view_keys
      @options.fetch(:views, [])
    end

    def default_view
      @options[:default_view]
    end
  end
end
