Networking
==========


open-vpn.yml
---------------

Installs and configures a basic [OpenVPN server](https://www.digitalocean.com/community/tutorials//how-to-set-up-an-openvpn-server-on-ubuntu-14-04). A bundled client profile (`client.ovpn`) as well as a CA certificate (`ca.crt`), user certificate (`client1.key`), and user private key (`client1.crt`) are generated and can be found in the `/root` directory. Use these with your [OpenVPN client software](https://www.digitalocean.com/community/tutorials//how-to-set-up-an-openvpn-server-on-ubuntu-14-04#step-5-installing-the-client-profile).

Uncomment the lines exporting indentity information for certificate and use you own information, or the defaults will be used.

**Optional input**:

* `<%COUNTRY%>`  - A 2-character country code (defaults to US).
* `<%PROVINCE%>` - A 2-character state or province code (defaults to CA).
* `<%CITY%>`     - City name (defaults to SanFrancisco).
* `<%ORG%>`      - Org/company name (defaults to Fort-Funston).
* `<%EMAIL%>`    - Email address (defaults to me@myhost.mydomain).
* `<%ORG_UNIT%>` - Orgizational unit / department (defaults to MyOrganizationalUnit).