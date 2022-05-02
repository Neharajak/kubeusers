# kubeusers
Generate local Authenticated Users for your Kubernetes Cluster 

# The Issue/Problem
While working with numerous clients on their Kubernetes cluster, I was surprised with the relative ease where I was given the cluster-admin privileges to work on their cluster. This 'cluster-admin' role essentially gives me FULL COMPLETE access to the cluster. While this makes my job a lot easier, it also poses a huge security issue for these busines owners and companies. Would you give the master key to your home to a stranger and say, 'hey, do what you want - here's the key' ??? 

# The Solution
Create a restricted local user in your Kubernetes cluster and grant only the required permissions to the consultant/contractor/freelancer who will be working on your cluster. 

If your Kubernetes cluster is linked to authentication provider (eg. LDAP, ActiveDirectory, OpenID, etc), then use that to create a custom user just for the job. If you do not have an authentication provider in your cluster, then create a 'local-user' via this 'kubeusers' script. 

# How to use 'kubeusers'
Download the script 'kubeuser.sh' into a directory. Ensure that you have a copy of the Kubernetes CA certificate (ca.crt) and CA key (ca.key) in the same directory. The Kubernetes CA files are typically found at /etc/kubernetes/pki on the Master node. 
These CA files will be used to sign the local-users' certificate.

# Step 1: Create the local-user
Example: Create user 'jim' that is valid for 5 days
$ ./kubeuser.sh jim 5

This will create a file called 'jim-kubeconfig.usr'
With this file, any person can access your Kubernetes cluster as the user 'jim'
  
# Step 2: Assign Roles/Privileges (RBAC) to this user
Let's say you want jim to work a deployment in the 'backend' namespace. Create a 'rolebinding' called 'jim-dev' for this local-user jim.
We'll make use of the built-in clusterrole 'edit' that allows jim to have full edit privileges in the 'backend' namespace. If we could also create a custom role with more fine-grained control/privileges (RBAC), but that's a topic for another day. 

$ kubectl -n backend create rolebinding jim-dev --clusterrole=edit --user=jim

# Step 3: Revoking access to the user
Once user 'jim' has completed the work, you can revoke his access via:

$ kubectl -n backend delete rolebinding jim-dev
