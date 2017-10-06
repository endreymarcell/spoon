# spoon

Easily SSH into EC2 nodes.  

## Examples

ssh to node by instance id
```bash
$ spoon 0ea4c7af85f59d112
[your-app-i-0ea4c7af85f59d112.ec2-us-east-1c:~] $
```

ssh to node by name (single hit)
```bash
$ spoon legacy
[legacy-logshipping-i-067d5a13188861066.ec2-us-east-1a:~] $
```

ssh to node by name (multiple hits)
```
$ spoon muladmin
*) all of the following (csshx)
1) muladminapp-app (running),         3) muladminapp-app (running),
2) muladminapp-app (running),         4) muladminapp-app-preprod (running)
#? 4
[muladminapp-app-preprod-i-a4c6dd4a.ec2-us-east-1e:~] $
``` 

## Usage
`spoon [identifier]`  
where identifier is either (a part of) the instance name, or the AWS instance ID (with or without the i- prefix).  
If only one instance matches, spoon instantiates the ssh connection directly. If more than one instances are found, spoon presents you with the list, where you can either choose a specific instance, or csshx into all of them.  