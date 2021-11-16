#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Get VPN config
# -------------------------------------------------------------------------------------------------------
# if [[ -f .openvpn/openvpn.ovpn ]]; then 
#   echo "=== VPN config already exists (.openvpn/openvpn.ovpn)"
# else
echo "=== Creating VPN config"
# Get vars from TF State
VPN_RG=$(terraform output -raw rg_name)
VPN_NAME=$(terraform output  -raw vpn_gateway_name)
VPN_ID=$(terraform output vpn_gateway_id)
VPN_CLIENT_CERT=$(terraform output client_cert)
VPN_CLIENT_KEY=$(terraform output client_key)
# Replace newlines with \n so sed doesn't break
VPN_CLIENT_CERT="${VPN_CLIENT_CERT//$'\n'/\\n}"
VPN_CLIENT_KEY="${VPN_CLIENT_KEY//$'\n'/\\n}"
echo "Generating vpn client for VPN Gateway: $VPN_ID"
CONFIG_URL=$(az network vnet-gateway vpn-client generate -n "$VPN_NAME" -g "$VPN_RG" -o tsv)
curl -o "vpnconfig.zip" "$CONFIG_URL"
# Ignore complaint about backslash in filepaths
unzip -o "vpnconfig.zip" -d "./vpnconftemp"|| true
OPENVPN_CONFIG_FILE="./vpnconftemp/OpenVPN/vpnconfig.ovpn"
echo "Updating file $OPENVPN_CONFIG_FILE"
sed -i "s~\$CLIENTCERTIFICATE~$VPN_CLIENT_CERT~" $OPENVPN_CONFIG_FILE
sed -i "s~\$PRIVATEKEY~$VPN_CLIENT_KEY~g" $OPENVPN_CONFIG_FILE
sed -i "s~log.*~log /var/log/openvpn.log~g" $OPENVPN_CONFIG_FILE
mkdir -p .openvpn
cp $OPENVPN_CONFIG_FILE .openvpn/openvpn.ovpn
rm -r ./vpnconftemp
rm vpnconfig.zip
#fi

#
# Update VM certs permissions so that we can use them to ssh into the machines
#
sudo chown -R vscode:vscode .ssh
sudo chmod 600 .ssh/rk2_id_rsa
sudo chmod 644 .ssh/rk2_id_rsa.pub

#
# Restart OpenVPN
#
"${DIR}"/tunnel-create.sh
sudo cp .openvpn/openvpn.ovpn /etc/openvpn/server.conf
sudo service openvpn restart
