echo "Clean current directory"
$appserviceFiles = "web.config", "deploy.ps1", "secret.txt" ,".gitignore", ".git"
Remove-Item -Path (Get-Item .\* -Exclude ($appserviceFiles)).FullName -Recurse -Force
if (Test-Path .\deploy) { Remove-Item .\deploy -Recurse -Force }

echo "Copy source files from ..\shields"
$sourceFiles = $appserviceFiles + "node_modules"
Copy-Item -Path (Get-Item -Path ..\shields\* -Exclude ($sourceFiles)).FullName -Destination . -Recurse -Force

echo "Run build"
npm install
npm run build
npm prune --production
npm cache clean --force

echo "Copy files to .\deploy directory"
Copy-Item -Path (Get-Item -Path ".\*" -Exclude (".*","deploy*", "Dockerfile", "secret.txt")).FullName -Destination ./deploy -Recurse -Force

echo "Create archive"
Compress-Archive  -Path ./Deploy/* -DestinationPath ./deploy.zip -CompressionLevel NoCompression

echo "Push archive to zip deploy"
curl -X POST -u (Get-Content .\secret.txt) https://abstrakt-shields.scm.azurewebsites.net/api/zipdeploy -T .\deploy.zip

echo "resulting website"
curl -I https://abstrakt-shields.azurewebsites.net
