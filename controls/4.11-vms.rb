# Copyright 2019 The inspec-gcp-cis-benchmark Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

title 'Ensure that Compute instances have Confidential Computing enabled '

gcp_project_id = input('gcp_project_id')
gce_zones = input('gce_zones')
cis_version = input('cis_version')
cis_url = input('cis_url')
control_id = '4.9'
control_abbrev = 'vms'

gce_instances = GCECache(project: gcp_project_id, gce_zones: gce_zones).gce_instances_cache

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 'medium'

  title "[#{control_abbrev.upcase}] Ensure that Compute instances have Confidential Computing enabled '"

  desc 'Google Cloud encrypts data at-rest and in-transit, but customer data must be decrypted for processing. Confidential Computing is a breakthrough technology which encrypts data in- use—while it is being processed. Confidential Computing environments keep data encrypted in memory and elsewhere outside the central processing unit (CPU).
  Confidential VMs leverage the Secure Encrypted Virtualization (SEV) feature of AMD EPYCTM CPUs. Customer data will stay encrypted while it is used, indexed, queried, or trained on. Encryption keys are generated in hardware, per VM, and not exportable. Thanks to built-in hardware optimizations of both performance and security, there is no significant performance penalty to Confidential Computing workloads.'
  desc 'rationale', "Confidential Computing enables customers' sensitive code and other data encrypted in memory during processing. Google does not have access to the encryption keys. Confidential VM can help alleviate concerns about risk related to either dependency on Google infrastructure or Google insiders' access to customer data in the clear."

  tag cis_scored: true
  tag cis_level: 2
  tag cis_gcp: control_id.to_s
  tag cis_version: cis_version.to_s
  tag project: gcp_project_id.to_s
  tag nist: ['SC-1']

  ref 'CIS Benchmark', url: cis_url.to_s
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/confidential-vm/docs/creating-cvm-instance'
  ref 'GCP Docs', url: 'https://cloud.google.com/compute/confidential-vm/docs/about-cvm'
  ref 'GCP Docs', url: 'https://cloud.google.com/confidential-computing'
  ref 'GCP Docs', url: 'https://cloud.google.com/blog/products/identity-security/introducing-google- cloud-confidential-computing-with-confidential-vms'

  gce_instances.each do |instance|
    describe "[#{gcp_project_id}] Instance #{instance[:zone]}/#{instance[:name]}" do
    subject {google_compute_instance(project: gcp_project_id, zone: instance[:zone], name: instance[:name])}
    its ('confidential_instance_config') { should be true }
    end
  end
end
