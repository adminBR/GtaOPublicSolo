# GtaOPublicSolo

A batch script to lock your public session in gta Online.

## Description

With few clicks you can close the ports who make connection with the rockstar servers, to be alone in a public server, and also create a whitelist of IPs to be able to play with friends.

## Getting Started

### Dependencies

* Tested only on windows 10 with the default firewall.
* Require admin permissions.

### Executing program

* Download the program.
* Click 2 times to launch.
* Press the correspondent to select an option on the terminal.

* (1-2) create ou remove the firewall rule who block the connection.
* (3-4) enable or disable the whitelist of IPs of the firewall rule.
* (5) create another whitelist of IPs, but you can also edit the 'whitelist.txt' manually, separating multiple ips with spaces.
* Ex.(10.0.0.1 192.168.1.1 255.255.255.0)

Obs. 
- If you edit manually the whitelist.txt, restart the script to load properly the IPs.
- To create the whitelist you need the External IP of the person who wants to join.
- The application can be used before or after the game is launched.
- This can't ban you because it's only work blocking ports on the firewall.

## Help

 * If you enable the rule after joined a public session, it may not work, if this happen you can just search for another session.
 * The script edit only the default windows firewall, if you have another firewall from a external application it may not work properly.
 
 * Know Bugs:
    * if the whitelist IPs are 1 number apart, the whitelist will not work

## Version History

* 0.2
    * Add the main script and the whitelist.txt
* 0.1
    * Initial Release

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
