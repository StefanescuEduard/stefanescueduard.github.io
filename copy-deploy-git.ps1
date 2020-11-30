Remove-Item -Path ".\.deploy_git\.github" -Recurse
Copy-Item -Path ".\.github" -Destination ".\.deploy_git" -Recurse
