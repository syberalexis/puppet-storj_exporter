# @summary  This class manages service
#
# @param ensure
#  State ensured from storj_exporter service.
# @param user
#  User running storj_exporter.
# @param group
#  Group under which storj_exporter is running.
# @param port
#  Storj exporter port (required to be accessible).
# @param storj_host_address
#  Storj host address.
# @param storj_api_port
#  Storj api port.
# @param bin_dir
#  Directory where binaries are located.
# @example
#   include storj_exporter::service
class storj_exporter::service (
  Variant[Stdlib::Ensure::Service, Enum['absent']] $ensure             = $storj_exporter::service_ensure,
  String                                           $user               = $storj_exporter::user,
  String                                           $group              = $storj_exporter::group,
  Stdlib::Port                                     $port               = $storj_exporter::port,
  Stdlib::Host                                     $storj_host_address = $storj_exporter::storj_host_address,
  Stdlib::Port                                     $storj_api_port     = $storj_exporter::storj_api_port,
  Stdlib::Absolutepath                             $bin_dir            = $storj_exporter::bin_dir,
) {
  $_file_ensure    = $ensure ? {
    'running' => file,
    'stopped' => file,
    default   => absent,
  }
  $_service_ensure = $ensure ? {
    'running' => running,
    default   => stopped,
  }

  file { '/lib/systemd/system/storj_exporter.service':
    ensure  => $_file_ensure,
    content => template('storj_exporter/service.erb'),
    notify  => Service['storj_exporter']
  }
  service { 'storj_exporter':
    ensure => $_service_ensure,
    enable => true,
  }

  File['/lib/systemd/system/storj_exporter.service'] -> Service['storj_exporter']
}
