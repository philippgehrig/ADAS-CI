import struct
import socket
import subprocess

def wake_on_lan(macaddress):
    """ Switches on remote computers using WOL. """
    if len(macaddress) == 12:
        pass
    elif len(macaddress) == 12 + 5:
        sep = macaddress[2]
        macaddress = macaddress.replace(sep, '')
    else:
        raise ValueError('Incorrect MAC address format')

    data = ''.join(['FFFFFFFFFFFF', macaddress * 20])
    send_data = []

    for i in range(0, len(data), 2):
        send_data.append(struct.pack('B', int(data[i: i + 2], 16)))

    send_data = b''.join(send_data)

    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        sock.sendto(send_data, ('<broadcast>', 9))

def deploy_on_pc(mac_address, path_to_software, software_version, pc_ip, ssh_user):
    # Wake the PC
    wake_on_lan(mac_address)

    # Connect to the PC using SSH and execute commands
    # SSH Key still needs to be added (still tbd how to do this)
    ssh_command = f"ssh {ssh_user}@{pc_ip}"
    git_command = f"cd {path_to_software} && git checkout {software_version}"

    # Execute the SSH command
    subprocess.run(f"{ssh_command} '{git_command}'", shell=True, check=True)

if __name__ == '__main__':
    from docopt import docopt

    """
    Usage:
      pipeline.py <mac_address> <path_to_software> <software_version> <pc_ip> <ssh_user> <ssh_password>

    Arguments:
      <mac_address>       The MAC address of the target PC.
      <path_to_software>  The path to the software on the target PC.
      <software_version>  The Git hash value of the version to be pulled.
      <pc_ip>             The IP address of the target PC.
      <ssh_user>          The SSH username for the target PC.
      <ssh_password>      The SSH password for the target PC.

    Options:
      -h --help  Show this screen.
    """
    # Parse the arguments from docopt
    arguments = docopt(__doc__)
    mac_address = arguments['<mac_address>']
    path_to_software = arguments['<path_to_software>']
    software_version = arguments['<software_version>']
    pc_ip = arguments['<pc_ip>']
    ssh_user = arguments['<ssh_user>']

    deploy_on_pc(mac_address, path_to_software, software_version, pc_ip, ssh_user)