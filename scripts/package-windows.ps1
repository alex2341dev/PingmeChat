Write-Output "$WINDOWN_PFX"
Move-Item -Path $WINDOWS_PFX -Destination pingmechat.pem
certutil -decode pingmechat.pem pingmechat.pfx

flutter pub run msix:create -c pingmechat.pfx -p $WINDOWS_PFX_PASS --sign-msix true --install-certificate false
