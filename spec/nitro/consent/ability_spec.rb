# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Consent::Ability do
  let(:user) { double(id: 1) }
  let(:permissions) { {} }
  let(:ability) { Consent::Ability.new(permissions, user) }

  it 'it authorizes symbol permissions' do
    permissions[:beta] = { lol_til_death: '1' }

    expect(ability).to be_able_to(:lol_til_death, :beta)
  end

  it 'it authorizes model permissions' do
    permissions[:some_model] = { action1: '1' }

    expect(ability).to be_able_to(:action1, SomeModel)
    expect(ability).to be_able_to(:action1, SomeModel.new)
  end

  it 'adds view conditions to cancan conditions' do
    permissions[:some_model] = { action1: :lol }

    expect(ability).to be_able_to(:action1, SomeModel)

    expect(ability).to be_able_to(:action1, SomeModel.new('lol'))
    expect(ability).to_not be_able_to(:action1, SomeModel.new('nop'))
  end

  it 'empty view means no permission' do
    permissions[:some_model] = { action1: '' }

    expect(ability).to_not be_able_to(:action1, SomeModel)
  end

  it '0 view means no permission' do
    permissions[:some_model] = { action1: 0 }

    expect(ability).to_not be_able_to(:action1, SomeModel)
  end

  it '"0" view means no permission' do
    permissions[:some_model] = { action1: '0' }

    expect(ability).to_not be_able_to(:action1, SomeModel)
  end

  it 'cannot perform action when instance condition forbids' do
    past = SomeModel.new(nil, Date.new - 10)
    future = SomeModel.new(nil, Date.new + 10)
    permissions[:some_model] = { destroy: :future }

    expect(ability).to_not be_able_to(:destroy, past)
    expect(ability).to be_able_to(:destroy, future)
  end
end
