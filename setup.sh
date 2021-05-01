#!/bin/bash
echo "You will be prompted for ID, Name, and Desc."
echo "ID is the package ID that comes after \"com.cyriaca.\""
echo "Name is the human-friendly package name."
echo "Desc is the package description."
echo

echo -n "ID: "
read UPM_ID
UPM_ID_UPPER=$(echo $UPM_ID | perl -wp -e '$_ = ucfirst')
echo -n "Name: "
read UPM_NAME

echo -n "Desc: "
read UPM_DESC

echo
echo "Package ID: $UPM_ID"
echo "Package name: $UPM_NAME"
echo "Package description: $UPM_DESC"
echo "Press enter to apply."
echo
read -n 1 -s
UPM_DATE=$(date +'%Y\-%m\-%d')
cat setup.txt | perl -pe 's/\n/\0/;' | xargs -0 sed -i ''\
    -e "s/ID_HERE/$UPM_ID/g"\
    -e "s/ID_UPPER_HERE/$UPM_ID_UPPER/g"\
    -e "s/NAME_HERE/$UPM_NAME/g"\
    -e "s/DESC_HERE/$UPM_DESC/g"\
    -e "s/DATE_HERE/$UPM_DATE/g"
mv Documentation~/ID_UPPER_HERE.md Documentation~/$UPM_ID_UPPER.md
mv Editor/Cyriaca.ID_UPPER_HERE.Editor.asmdef Editor/Cyriaca.$UPM_ID_UPPER.Editor.asmdef
mv Runtime/Cyriaca.ID_UPPER_HERE.asmdef Runtime/Cyriaca.$UPM_ID_UPPER.asmdef
mv Tests/Editor/Cyriaca.ID_UPPER_HERE.Editor.Tests.asmdef Tests/Editor/Cyriaca.$UPM_ID_UPPER.Editor.Tests.asmdef
mv Tests/Runtime/Cyriaca.ID_UPPER_HERE.Tests.asmdef Tests/Runtime/Cyriaca.$UPM_ID_UPPER.Tests.asmdef