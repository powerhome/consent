require 'spec_helper'

describe Nitro::Consent do
  describe '.define' do
    it 'creates a new subject with the given key and label' do
      Nitro::Consent.define(:lol_key, 'My Label') {}

      expect(Nitro::Consent.subjects[:lol_key].label).to eql 'My Label'
      expect(Nitro::Consent.subjects[:lol_key].key).to eql :lol_key
    end

    it 'yields a in dsl context' do
      build_context = nil
      Nitro::Consent.define(:lol_key, 'My Label') do
        build_context = self
      end

      expect(build_context).to be_a(Nitro::Consent::DSL)
      expect(build_context.subject).to be Nitro::Consent.subjects[:lol_key]
    end

    it 'yields a in dsl context with defaults' do
      defaults = { views: [:my_view] }

      block = -> (_, __) {}
      expect(Nitro::Consent::DSL).to receive(:build)
        .with(an_instance_of(Nitro::Consent::Subject), defaults, &block)

      Nitro::Consent.define :lol_key, 'My Label', defaults: defaults, &block
    end
  end

  describe '.permissions' do
    it 'maps a permissions hash to consent subjects' do
      permissions_hash = { some_model: { action1: :view1 } }

      permission = Nitro::Consent.permissions(permissions_hash).first

      expect(permission.subject_key).to be SomeModel
      expect(permission.action_key).to be :action1
      expect(permission.view_key).to be :view1
    end

    it 'maps symbol subjects' do
      permissions_hash = { features: { beta: true } }

      permission = Nitro::Consent.permissions(permissions_hash).first

      expect(permission.subject_key).to be :features
      expect(permission.action_key).to be :beta
      expect(permission.view_key).to be true
    end

    it 'empty view means no permission' do
      permissions_hash = { features: { beta: '' } }

      permissions = Nitro::Consent.permissions(permissions_hash)

      expect(permissions).to be_empty
    end

    it '0 view means no permission' do
      permissions_hash = { features: { beta: 0 } }

      permissions = Nitro::Consent.permissions(permissions_hash)

      expect(permissions).to be_empty
    end

    it '"0" view means no permission' do
      permissions_hash = { features: { beta: '0' } }

      permissions = Nitro::Consent.permissions(permissions_hash)

      expect(permissions).to be_empty
    end
  end
end
