require 'digest'

Puppet::Type.type(:vcenter_vrouter_map).provide(:ruby) do
  # commands 'script' => '/usr/local/bin/vcenter_vrouter_map'
  commands 'script' => '/bin/echo'

  attr_reader :resource

  MODE = 0100644

  # Run the external command to obtain the vcenter mapping
  # @return [String]
  def vrouter_map
    return @vrouter_map if @vrouter_map
    @vrouter_map = script '-p', resource[:password], '-u', resource[:username], '-s', resource[:vcenter_host], '-i', *resource[:ips]
    @vrouter_map += "\n" unless @vrouter_map.end_with? "\n"
    @vrouter_map
  end

  # Save the vcenter mapping to the file
  def save_vrouter_map
    File.open(resource[:path], 'w', MODE) do |file|
      file.write vrouter_map
    end
  end

  # Check if the existing file is the same as the newly generated one
  # @return [true,false]
  def compare_vrouter_map_data
    new_digest = Digest::SHA256.hexdigest vrouter_map
    old_digest = Digest::SHA256.file(resource[:path]).hexdigest rescue nil
    new_digest == old_digest
  end

  # Check if the vrouter file has the correct mode
  # @return [true,false]
  def check_mode_vrouter_map
    File.stat(resource[:path]).mode == MODE rescue false
  end

  #####

  def exists?
    return false unless File.exists? resource[:path]
    return true if resource[:ensure] == :absent
    compare_vrouter_map_data and check_mode_vrouter_map
  end

  def create
    destroy
    save_vrouter_map
  end

  def destroy
    return unless File.exists? resource[:path]
    File.unlink resource[:path]
  end

end
