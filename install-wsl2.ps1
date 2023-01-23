# PowerShell

# Distribution version
$version = "22.04"
$version_id = "jammy"

# Distribution name
$name = "Ubuntu-$version"

# Distribution download url
$image = "ubuntu-$version_id-wsl-amd64-wsl.rootfs.tar.gz"
$url = "https://cloud-images.ubuntu.com/wsl/$version_id/current/$image"
$download = "~/Downloads/$image"

# Where install will live
$install = "~/$name"
$install_disk = "$install/ext4.vhdx"

# User to create
$user = "harveyt"
$user_uid = "1000"
$user_gid = "1000"
$user_shell = "/bin/bash"

Write-Host "Setting up WSL2 with distribution '$name'..."

$existing = ((wsl --list --all) -replace "`0" | Select-Object -Skip 2 | Select-String -SimpleMatch -Pattern "$name") -join "`n"

if ($existing -eq "") {
    if (-not(Test-Path -Path $download -PathType Leaf)) {
	Write-Host "Downloading image from '$url'..."
	Invoke-WebRequest -Uri $url -OutFile $download -UseBasicParsing
    }

    if (-not(Test-Path -Path $install -PathType Container)) {
	Write-Host "Creating install directory at '$install'..."
	mkdir $install
    }

    if (-not(Test-Path -Path $install_disk -PathType Leaf)) {
       Write-Host "Importing '$name' to '$install'..."
       wsl --import $name (Convert-Path $install) (Convert-Path $download)
    }
}

$existing_user = (wsl -d $name sh -c "id $user 2>/dev/null") -join "`n"
if ($existing_user -eq "") {
   Write-Host "Creating '$user'..."
   wsl -d $name sh -c "`
	sudo addgroup --gid '${user_gid}' '${user}' \\`
	&& sudo adduser --uid '${user_uid}' --ingroup '${user}' \\`
			--gecos '' \\`
	                --shell '${user_shell}' '${user}' \\`
	&& sudo usermod --groups adm,dialout,cdrom,floppy,sudo,audio,dip,video,plugdev,netdev \\`
			'${user}' \\`
   "
}

$default_props = Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ `
   | Where-Object -Property DistributionName -eq $name
$default_uid = $default_props."DefaultUid"

if ($default_uid -eq 0) {
   Write-Host "Changing default user to '$user'..."
   Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ `
     | Where-Object -Property DistributionName -eq $name `
     | Set-ItemProperty -Name DefaultUid -Value $user_uid
}
