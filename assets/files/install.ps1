param
(
  # Use stable Bintray channel by default
  $channel = 'stable',
  # Set an empty version variable, signaling we want the latest release
  $Filter = '',
  # version to install. defaults to latest
  $version = '0.62.1',
  [switch]
  $Help,

  # Temporary Hackery
  [switch]
  $validate_archive

)

$BT_ROOT="https://api.bintray.com/content/habitat"
$BT_SEARCH="https://api.bintray.com/packages/habitat"
$os = $null
$arch = $null

# print_help() {
#   need_cmd cat
#   need_cmd basename

#   local _cmd
#   _cmd="$(basename "${0}")"
#   cat <<USAGE
# ${_cmd}

# Authors: The Habitat Maintainers <humans@habitat.sh>

# Installs the Habitat 'hab' program.

# USAGE:
#     ${_cmd} [FLAGS]

# FLAGS:
#     -c    Specifies a channel [values: stable, unstable] [default: stable]
#     -h    Prints help information
#     -v    Specifies a version (ex: 0.15.0, 0.15.0/20161222215311)

# ENVIRONMENT VARIABLES:
#      SSL_CERT_FILE   allows you to verify against a custom cert such as one
#                      generated from a corporate firewall

# USAGE
# }

function MAIN() {
    if($Help){
        #print help and exit
    }
    Write-Host -ForegroundColor Green "Installing Habitat 'hab' program"
    $platform_information = Get-Platform
    $workdir = Create-WorkDir
    $platform = Get-Platform
    $btv = Get-Version -version $version -platform $platform
    $files = Download-Archive -btv $btv -platform $platform -workdir $workdir
    write-host $files
    Verify-Archive -files $files
    $bin_dir = Extract-Archive -files $files -workdir $workdir -platform $platform_information
    Install-Hab -BinDir $bin_dir
    #   print_hab_version
    #   info "Installation of Habitat 'hab' program complete."
}

function Create-WorkDir(){
   $workdir = New-TemporaryDirectory
   cd $workdir.FullName
   #TODO:  install.sh has a trap here for cleaning things up
   return $workdir.FullName
}

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    $name = [System.IO.Path]::GetRandomFileName()
    New-Item -ItemType Directory -Path (Join-Path $parent "hab-$name")
}

function Get-Platform() {
    $os = $null
    $arch = $null
    if($env:os -ne "Windows_NT"){
        Write-Error "Unsupported OS type.  Expected Windows_NT, got $env:os."
        throw "Unsupported OS"
    }
    else {
        $os = 'windows'
    }
    if($env:PROCESSOR_ARCHITECTURE -eq $null){
        Write-Error "Processor architecture not found."
        throw "Processor architecture not found"
    }
    else {
        $arch_map = @{
            amd64 = "x86_64"
        }
        $arch = $arch_map[$env:PROCESSOR_ARCHITECTURE.ToLower()]
    }
    Write-Host -ForegroundColor Green "The following platform information will be used"
    $platform_information = @{
        sys = $os
        arch = $arch
        ext = "zip"
    }
    Write-Host (ConvertTo-Json $platform_information)
    return $platform_information
}

function Get-Version($version, $platform) {
    $arch = $platform['arch']
    $sys = $platform['sys']
    $_btv = $null
    $_j = $null
    $btv = $null
    if($version){
        Write-Host -ForegroundColor Green "Determining fully qualified version of package for $version"
        Write-Debug "${BT_SEARCH}/${channel}/hab-${arch}-${sys}"
        # TLS 1.2 required for bintray api. Powershell defaults to something lesser
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12;
        $version_map = Invoke-RestMethod -Method Get "${BT_SEARCH}/${channel}/hab-${arch}-${sys}"
        $fqvn = ($version_map.versions | ?{ $_ -like "*$version*"})
        if($fqvn){
            Write-Host -ForegroundColor Green "Using fully qualified Bintray version string of: $fqvn"
            $btv = $fqvn
        }
        else {
            $_e="Version `"${version}`" could not used or version doesn't exist."
            $_e="$_e Please provide a simple version like: `"0.15.0`""
            $_e="$_e or a fully qualified version like: `"0.15.0/20161222203215`"."
            throw $_e
        }
    }
    else{
        $btv = "%24latest"
    }
    return $btv
}

function Download-Archive($btv, $platform, $workdir, $validate_checksum) {
    $arch = $platform['arch']
    $sys = $platform['sys']
    $ext = $platform['ext']
    $url="${BT_ROOT}/${channel}/${sys}/${arch}/hab-${btv}-${arch}-${sys}.${ext}"
    $query="?bt_package=hab-${arch}-${sys}"

    $_hab_url="${url}${query}"
    $_sha_url="${url}.sha256sum${query}"
    Write-Debug "bin url: $_hab_url"
    Write-Debug "checksum url: $_sha_url"
    Invoke-WebRequest "${_hab_url}" -OutFile "${workdir}/hab-latest.${ext}"
    $archive=""
    $sha_file=$null

    # TODO: Back this out
    if($validate_checksum) {
        Invoke-WebRequest "${_sha_url}" -OutFile "${workdir}/hab-latest.${ext}.sha256sum"
        # TODO: Parse things
        #$archive="${workdir}/$(cut -d ' ' -f 3 hab-latest.${ext}.sha256sum)"
        $sha_file="${archive}.sha256sum"
    }
    else {
        $archive="${workdir}/hab-latest.${ext}"
        $sha_file=$null
    }
    Move-Item -Path "${workdir}/hab-latest.${ext}" -Destination $archive
    # TODO:  delete conditional wrapper
    if($sha_file){
        Move-Item -Path "${workdir}/hab-latest.${ext}.sha256sum" -Destination $sha_file
    }
    return @{
        archive=$archive
        sha_file=$sha_file
    }
}

function Verify-Archive($files){
    ## Dev Note ##
    ## I'm not sure if gpg verification is an expected thing in windows.
    ## Leaving bash code commented for reference and will circle up with
    ## Matt to see what the expectation is.
    ##
    #   if command -v gpg >/dev/null; then
    #     info "GnuPG tooling found, verifying the shasum digest is properly signed"
    #     local _sha_sig_url="${url}.sha256sum.asc${query}"
    #     local _sha_sig_file="${archive}.sha256sum.asc"
    #     local _key_url="https://bintray.com/user/downloadSubjectPublicKey?username=habitat"
    #     local _key_file="${workdir}/habitat.asc"

    #     dl_file "${_sha_sig_url}" "${_sha_sig_file}"
    #     dl_file "${_key_url}" "${_key_file}"

    #     gpg --no-permission-warning --dearmor "${_key_file}"
    #     gpg --no-permission-warning \
    #       --keyring "${_key_file}.gpg" --verify "${_sha_sig_file}"
    #   fi
    if($files['sha_file']){
        $archive_sha_sum = (Get-FileHash -Algorithm SHA256 -Path $files['archive']).Hash.ToLower()
        $sha_file_contents = (Get-Content -Path $files['sha_file']).ToLower()
        if( -not $sha_file_contents.Contains($archive_sha_sum.Hash)){
            throw "archive sha256sum does not match.`nexpected: ${sha_file_contents}`ngot: ${archive_sha_sum}"
        }
    }
}

function Extract-To-Directory($Path, $Destination){
    $PSVersion = $PSVersionTable.PSVersion
    if($PSVersion -ge [System.Version]"5.0"){
        Expand-Archive $Path -DestinationPath $Destination
    }
    Else{
        # .net 4.5 present, can load filesystem compression library
        $compression_library_loaded = $false
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $compression_library_loaded = $true
        }
        catch {
            Write-Host "Unable to load System.IO.Compression.FileSystem library (.net 4.5 required)"
            $compression_library_loaded = $false
        }
        if($compression_library_loaded){
            [System.IO.Compression.ZipFile]::ExtractToDirectory($Path, $Destination)
        }
        else {
            # default case, use expected prerequisite utility
            # TODO: TBD
            throw "generic zip not implemented"
        }
    }
}

function Extract-Archive($files, $workdir, $platform) {
    $arch = $platform['arch']
    $sys = $platform['sys']
    $archive = $files['archive']
    Write-Host -ForegroundColor Green "Extracting ${archive}"
    Extract-To-Directory -Path $archive -Destination $workdir
    return (Get-ChildItem -Path . -Directory).FullName | ? { $_ -like "*\hab*-$arch-$sys"}
}

function Install-Hab($BinDir){
}
# install_hab() {
#   case "${sys}" in
#     darwin)
#       need_cmd mkdir
#       need_cmd install

#       info "Installing hab into /usr/local/bin"
#       mkdir -pv /usr/local/bin
#       install -v "${archive_dir}"/hab /usr/local/bin/hab
#       ;;
#     linux)
#       local _ident="core/hab"
#       if [ ! -z "${version-}" ]; then _ident="${_ident}/$version"; fi
#       info "Installing Habitat package using temporarily downloaded hab"
#       # Install hab release using the extracted version and add/update symlink
#       "${archive_dir}/hab" install --channel "$channel" "$_ident"
#       # TODO fn: The updated binlink behavior is to skip targets that already
#       # exist so we want to use the `--force` flag. Unfortunetly, old versions
#       # of `hab` don't have this flag. For now, we'll run with the new flag and
#       # fall back to running the older behavior. This can be removed at a
#       # future date when we no lnger are worrying about Habitat versions 0.33.2
#       # and older. (2017-09-29)
#       "${archive_dir}/hab" pkg binlink "$_ident" hab --force \
#         || "${archive_dir}/hab" pkg binlink "$_ident" hab
#       ;;
#     *)
#       exit_with "Unrecognized sys when installing: ${sys}" 5
#       ;;
#   esac
# }

# print_hab_version() {
#   need_cmd hab

#   info "Checking installed hab version"
#   hab --version
# }

# info() {
#   echo "--> hab-install: $1"
# }

# warn() {
#   echo "xxx hab-install: $1" >&2
# }

# exit_with() {
#   warn "$1"
#   exit "${2:-10}"
# }

# main "$@" || exit 99

Main