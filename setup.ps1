$UPMReplacementTargets = @(
"Documentation~/NAME_HERE.md",
"Editor/COMPANY_HERE.NAME_HERE.Editor.asmdef",
"Runtime/COMPANY_HERE.NAME_HERE.asmdef",
"Tests/Editor/COMPANY_HERE.NAME_HERE.Editor.Tests.asmdef",
"Tests/Runtime/COMPANY_HERE.NAME_HERE.Tests.asmdef",
"CHANGELOG.md",
"LICENSE",
"package.json",
"README_TEMPLATE_.md"
)
$UPMMetaTargets = @(
"Editor",
"Editor/COMPANY_HERE.NAME_HERE.Editor.asmdef",
"Runtime",
"Runtime/COMPANY_HERE.NAME_HERE.asmdef",
"Tests",
"Tests/Editor",
"Tests/Editor/COMPANY_HERE.NAME_HERE.Editor.Tests.asmdef",
"Tests/Runtime",
"Tests/Runtime/COMPANY_HERE.NAME_HERE.Tests.asmdef",
"CHANGELOG.md",
"LICENSE",
"package.json",
"README_TEMPLATE_.md"
)
function Read-HostWithDefault {
    [CmdletBinding(DefaultParameterSetName = 'AsString')]
    Param(
        [Parameter(Position=0, ParameterSetName="AsString")]
        [Parameter(Position=0, ParameterSetName="AsSecureString")]
        [String] $Prompt,
        [Parameter(Position=1, ParameterSetName="AsString")]
        [Parameter(Position=1, ParameterSetName="AsSecureString")]
        [String] $DefaultValue,
        [Parameter(ParameterSetName="AsString")]
        [Switch] $MaskInput,
        [Parameter(ParameterSetName="AsSecureString")]
        [Switch] $AsSecureString
    )
    $result = Switch ($PSCmdlet.ParameterSetName)
    {
        "AsString" { Read-Host -Prompt $Prompt -MaskInput:$MaskInput }
        "AsSecureString" { Read-Host -Prompt $Prompt -AsSecureString:$AsSecureString }
    }
    if (-not($result)) { $DefaultValue }
    else { $result }
}
function Replace-ReplaceableValues {
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline)]
        [String] $Value,
        [Parameter(Mandatory=$true)]
        [HashTable] $Replacements
    )
    ForEach($key in $Replacements.Keys)
    {
        $Value = $Value.Replace($key.ToString(), $Replacements[$key])
    }
    $Value
}
function Write-UpmTemplatePackageData {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$true)] [String] $PackagePath,
        [Parameter(Mandatory=$true)] [HashTable] $Replacements
    )
    if($PSCmdlet.ShouldProcess($PackagePath))
    {
        $JsonReplacements = @{}
        ForEach ($replacementKey in $Replacements.Keys)
        {
            $replacementItem = ConvertTo-Json $Replacements[$replacementKey]
            $replacementItem = $replacementItem.Substring(1, $replacementItem.Length - 2)
            $JsonReplacements[$replacementKey] = $replacementItem
        }
        if (Test-Path "$PSScriptRoot/README.md") { Remove-Item "$PSScriptRoot/README.md" -Confirm:$false }
        if (Test-Path "$PSScriptRoot/omnisharp.json") { Remove-Item "$PSScriptRoot/omnisharp.json" -Confirm:$false }
        ForEach ($replacementFile in $UPMReplacementTargets)
        {
            $replacementFile = "$PSScriptRoot/$replacementFile"
			if (-not(Test-Path $replacementFile)) { continue }
            $replacedReplacementFile = Replace-ReplaceableValues -Value $replacementFile -Replacements $Replacements
            if ([System.IO.Path]::GetExtension($replacedReplacementFile) -eq ".json")
            {
                Get-Content `
                    -LiteralPath $replacementFile `
                    -Delimiter "$(%{ New-Guid })" `
                | Replace-ReplaceableValues `
                    -Replacements $JsonReplacements `
                | Set-Content `
                    -LiteralPath $replacedReplacementFile -Confirm:$false
            }
			else
			{
                Get-Content `
                    -LiteralPath $replacementFile `
                    -Delimiter "$(%{ New-Guid })" `
                | Replace-ReplaceableValues `
                    -Replacements $Replacements `
                | Set-Content `
                    -LiteralPath $replacedReplacementFile -Confirm:$false
			}
			if ($replacementFile -ne $replacedReplacementFile) { Remove-Item $replacementFile -Confirm:$false }
        }
        ForEach ($replacementFile in $UPMMetaTargets)
        {
            $replacementFile = "$PSScriptRoot/$replacementFile"
            $replacedReplacementFile = Replace-ReplaceableValues -Value $replacementFile -Replacements $Replacements
			if (-not(Test-Path $replacedReplacementFile)) { continue }
            $content = [System.Text.StringBuilder]::new()
            [void]$content.AppendLine("fileFormatVersion: 2")
            [void]$content.AppendLine("guid: $([System.Guid]::NewGuid().ToString("N"))")
            if (Test-Path $replacedReplacementFile -PathType Container)
            {
                [void]$content.AppendLine("DefaultImporter:")
            }
            elseif ([System.IO.Path]::GetFileName($replacedReplacementFile) -eq "package.json")
            {
                [void]$content.AppendLine("PackageManifestImporter:")
            }
            else
            {
                $v = Switch ([System.IO.Path]::GetExtension($replacedReplacementFile))
                {
                    ".md" { "TextScriptImporter:" }
                    ".txt" { "TextScriptImporter:" }
                    ".asmdef" { "AssemblyDefinitionImporter:" }
                    default { "DefaultImporter:" }
                }
                [void]$content.AppendLine($v)
            }
            [void]$content.AppendLine(@"
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
"@)
            $path = "$($replacedReplacementFile.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)).meta"
            Set-Content -LiteralPath $path $content.ToString() -Confirm:$false
        }
    }
}
$Replacements = @{
PACKAGE_PREFIX = Read-HostWithDefault @"
Enter package prefix, e.g. 'com', 'net'
Value
"@;
COMPANY_HERE = Read-HostWithDefault @"
Enter company name (single word for package identifier), e.g. 'Contoso'
Value
"@;
COMPANY_LONG_HERE = Read-HostWithDefault @"
Enter Company name (long), e.g. 'Contoso Corporation'
Value
"@;
NAME_HERE = Read-HostWithDefault @"
Enter package name (for package identifier), e.g. 'Utility', 'Fabrikam.Scripting'
Value
"@;
NAME_DISPLAY_HERE = Read-HostWithDefault @"
Enter package name (for display), e.g. 'Internal Utilities', 'Scripting for Fabrikam Framework'
Value
"@;
DESC_HERE = Read-HostWithDefault @"
Enter description (for package manifest)
Value
"@;
}
$Replacements["COMPANY_LOWER_HERE"] = $Replacements["COMPANY_HERE"].ToLowerInvariant()
$Replacements["NAME_LOWER_HERE"] = $Replacements["NAME_HERE"].ToLowerInvariant()
$Replacements["DATE_HERE"] = [System.DateTime]::UtcNow.ToString("yyyy-M-d")
$Replacements["YEAR_HERE"] = [System.DateTime]::UtcNow.ToString("yyyy")
$Replacements["_TEMPLATE_"] = ""
Write-UpmTemplatePackageData -PackagePath $PSScriptRoot -Replacements $Replacements -Confirm