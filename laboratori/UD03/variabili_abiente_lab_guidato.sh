export LAB_SUFFIX="$(openssl rand -hex 3)"
export LAB_RG="rg-cea-identity-${LAB_SUFFIX}"
export LAB_LOCATION="italynorth"
export LAB_DELETE_AFTER="$(date -u -d '+1 day' +%F)"
