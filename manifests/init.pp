# @summary This module manages Storj Exporter
#
# Init class of Storj Exporter module. It can installes Storj Exporter binaries and single Service.
#
# @param version
#  Storj exporter release. See https://github.com/anclrii/Storj-Exporter/releases
# @param base_dir
#  Base directory where Storj is extracted.
# @param bin_dir
#  Directory where binaries are located.
# @param download_extension
#  Extension of Storj exporter binaries archive.
# @param download_url
#  Complete URL corresponding to the Storj exporter release, default to undef.
# @param extract_command
#  Custom command passed to the archive resource to extract the downloaded archive.
# @param manage_user
#  Whether to create user for storj_exporter or rely on external code for that.
# @param manage_group
#  Whether to create user for storj_exporter or rely on external code for that.
# @param user
#  User running storj_exporter.
# @param group
#  Group under which storj_exporter is running.
# @param usershell
#  if requested, we create a user for storj_exporter. The default shell is false. It can be overwritten to any valid path.
# @param extra_groups
#  Add other groups to the managed user.
# @param service_ensure
#  State ensured from storj_exporter service.
# @param port
#  Storj exporter port (required to be accessible).
# @param storj_host_address
#  Storj host address.
# @param storj_api_port
#  Storj api port.
# @param manage_python
#  Whether to install python3 or rely on external code for that.
#  Python3 is required to run exporter binary.
# @param python_required_packages
#  Python required package list.
# @example
#   include storj_exporter
class storj_exporter (
  Pattern[/\d+\.\d+\.\d+/]                         $version                  = '0.2.5',

  # Installation
  Stdlib::Absolutepath                             $base_dir                 = '/opt',
  Stdlib::Absolutepath                             $bin_dir                  = '/usr/local/bin',
  Stdlib::HTTPUrl                                  $base_url                 = 'https://github.com/anclrii/Storj-Exporter/archive',
  String                                           $download_extension       = 'tar.gz',
  Optional[Stdlib::HTTPUrl]                        $download_url             = undef,
  Optional[String]                                 $extract_command          = undef,

  # User Management
  Boolean                                          $manage_user              = true,
  Boolean                                          $manage_group             = true,
  String                                           $user                     = 'storj_exporter',
  String                                           $group                    = 'storj_exporter',
  Stdlib::Absolutepath                             $usershell                = '/bin/false',
  Array[String]                                    $extra_groups             = [],

  # Service
  Variant[Stdlib::Ensure::Service, Enum['absent']] $service_ensure           = 'running',
  Stdlib::Port                                     $port                     = 14002,
  Stdlib::Host                                     $storj_host_address       = '127.0.0.1',
  Stdlib::Port                                     $storj_api_port           = 9651,

  # Extra Management
  Boolean                                          $manage_python            = true,
  Array[String]                                    $python_required_packages = ['requests', 'prometheus_client'],
) {
  if $download_url {
    $real_download_url = $download_url
  } else {
    $real_download_url = "${base_url}/v${version}.${download_extension}"
  }

  include storj_exporter::install
  include storj_exporter::service

  Class['storj_exporter::install'] -> Class['storj_exporter::service']

  if $manage_python {
    class { 'python':
      version => '3',
    }

    Class['python'] -> Class['storj_exporter::service']
  }
}
