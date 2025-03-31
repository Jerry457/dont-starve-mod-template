# param (
#     [string]$type
# )

$postinitFolder = Join-Path $PSScriptRoot "postinit"
$postinitFiles = Get-ChildItem $postinitFolder -Recurse -Filter *.lua
$postinits = @()
foreach ($postinitFile in $postinitFiles) {
    $relativePath = $postinitFile.FullName.Substring($postinitFolder.Length + 1)
    $relativePath = $relativePath.Replace("\", "/")
    $postinits += "    `"postinit/$($relativePath)`""
}

$postinitString = "local files = {`n" + ($postinits -join ",`n") + "`n}`n"
$postinitString += "`nfor _, file in ipairs(files) do`n    modimport(file)`nend"
$postinitString | Out-File -FilePath (Join-Path $PSScriptRoot "main/postinit.lua") -Encoding utf8

$prefabFolder = Join-Path $PSScriptRoot "scripts/prefabs"
$prefabFiles = Get-ChildItem $prefabFolder -Recurse -Filter *.lua
$prefabs = @()
foreach ($prefabFile in $prefabFiles) {
    $relativePath = $prefabFile.FullName.Substring($prefabFolder.Length + 1)
    $relativePath = $relativePath.Replace("\", "/")
    $relativePath = $relativePath.Replace(".lua", "")
    $prefabs += "    `"$($relativePath)`""
    write-host $relativePath
}
$prefabString = "PrefabFiles = {`n" + ($prefabs -join ",`n") + "`n}"
$prefabString | Out-File -FilePath (Join-Path $PSScriptRoot "main/prefab_files.lua") -Encoding utf8
