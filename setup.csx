var company = Get("Company", "Cyriaca");
var companyLong = Get("Company (long)", "Cyriaca Software");
var name = Get("Name");
var displayName = Get("Display name");
var desc = Get("Description");

var companyLower = company.ToLowerInvariant();
var nameLower = name.ToLowerInvariant();
var date = DateTime.UtcNow.ToString("yyyy-M-d");
var year = DateTime.UtcNow.ToString("yyyy");

WriteLine($@"
Company: {company}
Company (long): {companyLong}
Name: {name}
Display name: {displayName}
Description: {desc}
Today's date: {date}

Press enter to apply.");

ReadLine();

string Replace(string str) => str
    .Replace("COMPANY_HERE", company)
    .Replace("COMPANY_LONG_HERE", companyLong)
    .Replace("NAME_HERE", name)
    .Replace("NAME_DISPLAY_HERE", displayName)
    .Replace("DESC_HERE", desc)
    .Replace("COMPANY_LOWER_HERE", companyLower)
    .Replace("NAME_LOWER_HERE", nameLower)
    .Replace("DATE_HERE", date)
    .Replace("YEAR_HERE", year);

string Get(string prompt, string def = null)
{
    Write(def != null ? $@"{prompt} [""{def}""]: " : $"{prompt}: ");
    var res = ReadLine();
    return !string.IsNullOrWhiteSpace(res) || def == null ? res : def;
}

foreach (var path in @"
Documentation~/NAME_HERE.md
Editor/COMPANY_HERE.NAME_HERE.Editor.asmdef
Runtime/COMPANY_HERE.NAME_HERE.asmdef
Tests/Editor/COMPANY_HERE.NAME_HERE.Editor.Tests.asmdef
Tests/Runtime/COMPANY_HERE.NAME_HERE.Tests.asmdef
CHANGELOG.md
LICENSE
package.json
README.md
".Split(new char[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries))
{
    var alt = Replace(path);
    File.WriteAllText(alt, Replace(File.ReadAllText(path)));
    if (alt != path) File.Delete(path);
}


foreach (var path in $@"
Editor
Editor/COMPANY_HERE.NAME_HERE.Editor.asmdef
Runtime
Runtime/COMPANY_HERE.NAME_HERE.asmdef
Tests
Tests/Editor
Tests/Editor/COMPANY_HERE.NAME_HERE.Editor.Tests.asmdef
Tests/Runtime
Tests/Runtime/COMPANY_HERE.NAME_HERE.Tests.asmdef
CHANGELOG.md
LICENSE
package.json
README.md
".Split(new char[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries))
{
    using var writer = File.CreateText($"{Replace(path).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)}.meta");
    var name = Path.GetFileName(path);
    var ext = Path.GetExtension(path);
    writer.WriteLine($@"
fileFormatVersion: 2
guid: {Guid.NewGuid().ToString("N")}".TrimStart());
    if (Directory.Exists(path))
        writer.WriteLine(@"
folderAsset: yes
DefaultImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: ".TrimStart());
    else if (name == "package.json")
        writer.WriteLine(@"
PackageManifestImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: ".TrimStart());
    else if (ext == "md" || ext == "txt")
        writer.WriteLine(@"
TextScriptImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: ".TrimStart());
    else if (ext == "asmdef")
        writer.WriteLine(@"
".TrimStart());
    else
        writer.WriteLine(@"
DefaultImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: ".TrimStart());
}