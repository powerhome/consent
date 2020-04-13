# frozen_string_literal: true

module Consent
  # Defines a CanCan(Can)::Ability class based on a permissions hash
  class Ability
    include CanCan::Ability

    def initialize(*args)
      @context = *args
      apply_defaults
    end

    def consent(permission: nil, subject: nil, action: nil, view: nil)
      permission ||= Permission.new(subject, action, view)
      conditions = permission.conditions(*@context)
      ocond = permission.object_conditions(*@context)

      can permission.action_key, permission.subject_key, conditions, &ocond
    end

  private

    def apply_defaults
      Consent.subjects.each do |subject|
        subject.actions.map do |action|
          next unless action.default_view
          consent subject: subject.key, action: action.key, view: action.default_view
        end
      end
    end
  end
end
