# Projet 07, lab 6 — inspec exec inspec -t azure://
control 'resource-group' do
  describe azure_resource_group(name: 'devopsjourney-rg') do
    it { should exist }
    its('location') { should cmp 'francecentral' }
  end
end

control 'aks-cluster' do
  describe azure_aks_cluster(resource_group: 'devopsjourney-rg', name: 'devopsjourneyaks') do
    it { should exist }
    its('properties.provisioningState') { should cmp 'Succeeded' }
  end
end

control 'container-registry' do
  describe azure_container_registry(resource_group: 'devopsjourney-rg', name: input('acr_name', value: 'devopsjourneyacr12345')) do
    it { should exist }
    its('properties.adminUserEnabled') { should be false }
  end
end
