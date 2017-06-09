# spoon

Easily SSH into EC2 nodes.  

## Usage
`spoon [identifier]`  
where identifier is either (a part of) the instance name, or the AWS instance ID (with or without the i- prefix).  
If only one instance matches, spoon instantiates the ssh connection directly. If more than one instances are found, spoon presents you with the list, where you can either choose a specific instance, or csshx into all of them.  