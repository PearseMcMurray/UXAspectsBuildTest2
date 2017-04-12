#!/bin/bash
set -e

SELENIUM_TEST_MACHINE_USER=UXAspectsTestUser

UX_ASPECTS_BUILD_IMAGE_NAME=ux-aspects-build
UX_ASPECTS_BUILD_IMAGE_TAG_LATEST=0.7.0

echo Workspace is $WORKSPACE
echo NextVersion is $NextVersion
echo RunTests is $RunTests
echo HttpProxy is $HttpProxy
echo HttpsProxy is $HttpsProxy
echo BuildPackages is $BuildPackages
echo PrivateArtifactoryURL is $PrivateArtifactoryURL
echo PrivateArtifactoryCredentials is $PrivateArtifactoryCredentials
echo BuildDocumentation is $BuildDocumentation
echo GridHubIPAddress is $GridHubIPAddress
echo Build number is $BUILD_NUMBER
echo Build image is $UX_ASPECTS_BUILD_IMAGE_NAME:$UX_ASPECTS_BUILD_IMAGE_TAG_LATEST
echo SSH logon is $SELENIUM_TEST_MACHINE_USER@$GridHubIPAddress
echo UID is $UID
echo GROUPS is $GROUPS
echo USER is $USER
echo PWD is $PWD
echo HOME is $HOME
#echo Displaying groups
#groups
#echo Displaying id
#id

# Get ID of latest commit to develop branch
echo Moving to workspace
cd $WORKSPACE
latestCommitID=`git rev-parse HEAD`
echo latestCommitID is $latestCommitID




# Temporary commands to allow testing of Jenkins job
#echo Listing contents of $WORKSPACE
#ls -alR $WORKSPACE
#cd $WORKSPACE
#cp $WORKSPACE/buildscripts/emailable-report.html index.html
#cp $WORKSPACE/buildscripts/testng-results.xml .
#mkdir -p $WORKSPACE/reports
#cp index.html $WORKSPACE/reports/index.html

#echo Exiting early ...
#exit 0


# Create the latest ux-aspects-build image if it does not exist
#!!!!!!!!!!!docker_image_build; echo

# TBD - Execute unit tests

# TBD - Execute Selenium tests

echo Both sets of tests passed. Performing the build.
cd $WORKSPACE
#!!!!!!!!!!!!!!!!!!!!cp /home/jenkins/.bowerrc .

# TBD - Remove remnants of tests

# Read the bower.json name attribute
bn=$(grep '\"name\"\: ' bower.json | awk '{print $2}')
# Remove multiple characters " and ,
bowerName="$(sed 's/[",]//g' <<< "$bn")";
bowerName=$(echo $bowerName|tr -d '\n')
echo "Bower name = $bowerName"

# Bump up the version in package.json
sed -i -e s/"\"version\": \"[0-9]\.[0-9]\.[0-9].*\","/"\"version\": \"$NextVersion\","/ "package.json"
newPackageVersion=`cat package.json | grep version`
if [[ $newPackageVersion == *"$NextVersion"* ]]
then
   echo "Updated package.json with $NextVersion"
else
   echo "ERROR: package.json isn't updated with $NextVersion"
   exit 1
fi

# Updating the version in footer-navigation.json and landing-page.json
echo
echo Update the version in footer-navigation.json and landing-page.json
sed -i -e s/"\"title\": \"Currently v*[0-9]\.[0-9]\.[0-9].*\","/"\"title\": \"Currently v$NextVersion\","/ "docs/app/data/footer-navigation.json"
sed -i -e s/"\"version\": \"Currently v*[0-9]\.[0-9]\.[0-9].*\","/"\"version\": \"Currently v$NextVersion\","/ "docs/app/data/landing-page.json"

# Take a copy of the files which will be overwritten by the HPE theme files
echo
echo Copy the Keppel theme files
mkdir $WORKSPACE/KeppelThemeFiles
cp -p -r $WORKSPACE/src/fonts $WORKSPACE/KeppelThemeFiles
cp -p -r $WORKSPACE/src/img $WORKSPACE/KeppelThemeFiles
cp -p -r $WORKSPACE/src/styles $WORKSPACE/KeppelThemeFiles

# Get the HPE theme files and copy them onto the source hierarchy
echo
echo Get the HPE theme files
mkdir $WORKSPACE/HPEThemeFiles
cd $WORKSPACE/HPEThemeFiles
curl -L -S -s https://github.hpe.com/caf/ux-aspects-hpe/archive/master.zip > HPETheme.zip
unzip -o HPETheme.zip
cp -p -r ux-aspects-hpe-master/fonts $WORKSPACE/src
cp -p -r ux-aspects-hpe-master/img $WORKSPACE/src
cp -p -r ux-aspects-hpe-master/styles $WORKSPACE/src

# Build using the HPE theme
echo
echo Building using the HPE theme
cd $WORKSPACE
echo Run npm install
npm install				# !!! docker_image_run
echo Building
grunt clean				# !!! docker_image_run
grunt build --force		# !!! docker_image_run

# Archive the HPE-themed documentation files
echo
echo Archiving the HPE-themed documentation files
mv dist/docs docs-gh-pages-HPE-$NextVersion
cd docs-gh-pages-HPE-$NextVersion
tarDocs=`tar -czvf ../$NextVersion-docs-gh-pages-HPE.tar.gz *`
echo "$tarDocs"
cd ..

# Create HPE Bower package tarball for Artifactory
cd $WORKSPACE
HPEPackage="${bowerName}_$NextVersion.tar.gz"
echo
echo Creating HPE Bower package $HPEPackage
cdir=`pwd`
rm -rf $HPEPackage
mkdir dist/css
cp -p dist/styles/ux-aspects.css dist/css
tar czvf $HPEPackage dist/css dist/fonts dist/img dist/styles bower.json
if [ "$?" -eq 0 ]
then
    echo "Package $HPEPackage was Successfully created"
    ls -la "$cdir/$HPEPackage"
else
    echo "Error: Creating package $HPEPackage"
fi

# Upload HPE-themed package to Artifactory
echo
echo Uploading HPE-themed package to Artifactory
cd $WORKSPACE
echo "curl -XPUT $PrivateArtifactoryURL/$HPEPackage -T $cdir/$HPEPackage"
curl -u $PrivateArtifactoryCredentials -XPUT $PrivateArtifactoryURL/$HPEPackage -T $cdir/$HPEPackage
rm -rf $HPEPackage

# Remove the HPE theme files
echo
echo Deleting the HPE theme files
rm -rf $WORKSPACE/src/fonts
rm -rf $WORKSPACE/src/img
rm -rf $WORKSPACE/src/styles

# Copy back the Keppel theme files
echo
echo Restoring the Keppel theme files
cp -p -r $WORKSPACE/KeppelThemeFiles/* $WORKSPACE/src

# Build using the Keppel theme
echo
echo Building using the Keppel theme
cd $WORKSPACE
grunt clean				# !!! docker_image_run
rm -rf dist
grunt build --force		# !!! docker_image_run

# Archive the Keppel-themed documentation files
echo
echo Archiving the Keppel-themed documentation files
mv dist/docs docs-gh-pages-Keppel-$NextVersion
cd docs-gh-pages-Keppel-$NextVersion
tarDocs=`tar czvf ../$NextVersion-docs-gh-pages-Keppel.tar.gz *`
echo "$tarDocs"
cd ..

# Create a branch for the new documentation. Stash altered files for later.
echo
echo Creating the branch $NextVersion-gh-pages-test
cd $WORKSPACE
git checkout docs/app/data/footer-navigation.json
git checkout docs/app/data/landing-page.json
git add package.json
git stash
git checkout gh-pages
git checkout -b $NextVersion-gh-pages-test
git push origin $NextVersion-gh-pages-test

# Delete files which are not to be added to the branch
echo
echo Deleting files which are not to be added to the branch
rm -rf assets/ docs/
rm -f *.css *.html *.js *.log

# Extract the files from the Keppel documentation archive, both to this folder and to a $NextVersion sub-directory.
echo
echo Extracting the files from the Keppel documentation archive
tar xvf $NextVersion-docs-gh-pages-Keppel.tar.gz
if [ -d "$NextVersion" ]; then
    echo "Folder $NextVersion exists... deleting it!"
    rm -rf $NextVersion
fi
mkdir $NextVersion
cd $NextVersion
tar xvf ../$NextVersion-docs-gh-pages-Keppel.tar.gz
cd ..

# Push the required files to the branch
echo
echo Pushing the required files to the branch
git add $NextVersion/ assets/ docs/ *.css *.html *.js
git commit -a -m "Committing documentation changes for $NextVersion-gh-pages-test. Latest commit ID is $latestCommitID."
git push origin $NextVersion-gh-pages-test

# Return to the develop branch and retrieve the stashed files
echo
echo Returning to the develop branch
cd $WORKSPACE
git checkout develop
git stash pop

# Create the new branch for the Keppel bower package
echo
echo Creating the branch $NextVersion-package-test
git checkout -b $NextVersion-package-test
git push origin $NextVersion-package-test

# Remove files and folders which are not to be committed
echo
echo Removing files which are not to be committed
rm -rf docs-gh-pages-HPE-$NextVersion/
rm -rf docs-gh-pages-Keppel-$NextVersion/
rm -rf HPEThemeFiles/
rm -rf KeppelThemeFiles/
rm -f *.gz

# Push the changes
echo
echo Pushing the changes
git add -A
git commit -m "Committing changes for package $NextVersion-test. Latest commit ID is $latestCommitID."
git push --set-upstream origin $NextVersion-package-test

# Return to the develop branch
echo
echo Returning to the develop branch
git checkout develop

exit 0