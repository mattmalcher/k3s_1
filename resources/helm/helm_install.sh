#!/usr/bin/env bash
source helm_install_funs.sh

initArch
initOS
verifySupported
checkDesiredVersion
if ! checkHelmInstalledVersion; then
  #downloadFile
  #verifyFile
  get_paths
  installFile
fi
testVersion
#cleanup