A first go at playing with local kubernetes deployments.

Decisions:
 - use vagrant - I want a setup that looks more like a bunch of ec2 instances than minikube would.
 - k3s? k0s? microk8s?- Dont care, lets get started and change if need be.
 - use ansible - for practice
 - try to keep track of downloads so I could reproduce in airgapped env


# Portainer

```sh
kubectl apply -n portainer -f https://raw.githubusercontent.com/portainer/k8s/master/deploy/manifests/portainer/portainer.yaml

```

http://192.168.56.31:30777/#!/wizard


# Problems

## Set up NFS for the swarm on the vagrant/ansible host

I want NFS to be accessible from both the host & the swarm for convenience.

https://linuxize.com/post/how-to-install-and-configure-an-nfs-server-on-ubuntu-20-04/

This makes an nfs folder at /srv/nfs4/k3s_1 and allows the virtualbox subnet on 192.168.56.x to access it.

`no_root_squash` is a security issue as a remote root user can then gain root on the NFS server. 

What does EFS do here? (EFS Uses no_root_squash!)

```
sudo apt update
sudo apt install nfs-kernel-server
sudo mkdir -p /srv/nfs4/k3s_1
sudo chown 1000 /srv/nfs4/k3s_1
sudo bash -c 'echo "/srv/nfs4    192.168.56.0/24(rw,sync,no_root_squash,no_subtree_check,crossmnt,fsid=0)" >> /etc/exports'
sudo bash -c 'echo "/srv/nfs4/k3s_1    192.168.56.0/24(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports'
sudo exportfs -ar
```

This should result in an exports file that looks like:

```
/srv/nfs4         192.168.56.0/24(rw,sync,no_root_squash,no_subtree_check,crossmnt,fsid=0)
/srv/nfs4/k3s_1    192.168.56.0/24(rw,sync,no_root_squash,no_subtree_check)
```

Note - vagrant does have some functionality to automatically set up NFS for you...


## Issues with agent joining

Was getting errors like the following on the agent.
`Remotedialer proxy error    error="dial tcp 10.0.2.15:6443: connect: connection refused"`

Turns out, the agent is unable to join unless you specify `extra_server_args: "--advertise-address 192.168.56.30"` in `group_vars/all.yml`
See: https://github.com/alexellis/k3sup/issues/306#issuecomment-1059986048


## Getting kubectl to work on host

Pretty easy to set up `kubectl` to use this new cluster:

Copy the config out of the k3s.yaml to the nfs share.
```
vagrant ssh k3-srv-1
sudo cat /etc/rancher/k3s/k3s.yaml > /mnt/efs/config
```

Then on host
```
cp /srv/nfs4/k3s/config ~/.kube/config
```


# Refs
https://blog.flant.com/small-local-kubernetes-comparison/


## Using Vagrant
https://levelup.gitconnected.com/local-kubernetes-development-using-vagrant-and-k3s-547bd5687a7f


## Airgapping
https://rancher.com/docs/k3s/latest/en/installation/airgap/
https://rancher.com/docs/k3s/latest/en/installation/private-registry/ - how 


## Setting up K3s as a service
https://github.com/k3s-io/k3s/blob/master/k3s.service

## Using Ansible
This is gold:
https://github.com/k3s-io/k3s-ansible


# Next

Get some applications deployed! 

* jupyter w kubespawner?
* freeipa?


* Get a reverse proxy/ingress working