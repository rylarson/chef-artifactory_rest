require 'serverspec'

set :backend, :exec

describe file('/tmp/commons-io.jar') do
  it { is_expected.to exist }
  its(:md5sum) { is_expected.to eq '7f97854dc04c119d461fed14f5d8bb96' }
end
