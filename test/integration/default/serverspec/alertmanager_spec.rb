require_relative '../../../kitchen/data/spec_helper'

describe service('alertmanager') do
  it { should be_running.under('supervisor') }
end

