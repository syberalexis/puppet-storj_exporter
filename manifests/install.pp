# @summary This class install Storj exporter requirements and binaries.
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
# @param user_shell
#  if requested, we create a user for storj_exporter. The default shell is false. It can be overwritten to any valid path.
# @param extra_groups
#  Add other groups to the managed user.
# @param python_required_packages
#  Python required package list.
# @example
#   include storj_exporter::install
class storj_exporter::install (
  Pattern[/\d+\.\d+\.\d+/] $version                  = $storj_exporter::version,
  Stdlib::Absolutepath     $base_dir                 = $storj_exporter::base_dir,
  Stdlib::Absolutepath     $bin_dir                  = $storj_exporter::bin_dir,
  String                   $download_extension       = $storj_exporter::download_extension,
  Stdlib::HTTPUrl          $download_url             = $storj_exporter::real_download_url,
  Optional[String]         $extract_command          = $storj_exporter::extract_command,

  # User Management
  Boolean                  $manage_user              = $storj_exporter::manage_user,
  Boolean                  $manage_group             = $storj_exporter::manage_group,
  String                   $user                     = $storj_exporter::user,
  String                   $group                    = $storj_exporter::group,
  Stdlib::Absolutepath     $user_shell               = $storj_exporter::user_shell,
  Array[String]            $extra_groups             = $storj_exporter::extra_groups,

  # Python dependencies
  Array[String]            $python_required_packages = $storj_exporter::python_required_packages,
) {
  archive { "/tmp/storj-exporter-${version}.${download_extension}":
    ensure          => 'present',
    extract         => true,
    extract_path    => $base_dir,
    source          => $download_url,
    checksum_verify => false,
    creates         => "${base_dir}/Storj-Exporter-${version}",
    cleanup         => true,
    extract_command => $extract_command,
  }
  file {
    "${base_dir}/Storj-Exporter-${version}/storj-exporter.py":
      owner => 'root',
      group => 0, # 0 instead of root because OS X uses "wheel".
      mode  => '0555';
    "${bin_dir}/storj-exporter":
      ensure => link,
      target => "${base_dir}/Storj-Exporter-${version}/storj-exporter.py";
  }

  Archive["/tmp/storj-exporter-${version}.${download_extension}"]
  -> File["${base_dir}/Storj-Exporter-${version}/storj-exporter.py"]
  -> File["${bin_dir}/storj-exporter"]

  if $manage_user {
    ensure_resource('user', [ $user ], {
      ensure => 'present',
      system => true,
      groups => concat([$group], $extra_groups),
      shell  => $user_shell,
    })

    if $manage_group {
      Group[$group] -> User[$user]
    }
  }
  if $manage_group {
    ensure_resource('group', [ $group ], {
      ensure => 'present',
      system => true,
    })
  }

  # Python dependencies
  if $python_required_packages {
    $python_required_packages.each |String $package| {
      ensure_resource('python::pip', $package, {
        ensure       => 'present',
        pkgname      => $package,
        pip_provider => 'pip3',
      })
    }
  }
}
