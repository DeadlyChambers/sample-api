# RBAC (RoleBasedAccessControl)
These are the structures put in place to control access to users, and services using roles. There are 3 main connections.

**Role or ClusterRole** Is a set of rules that represent a set of permissions. A _role_ can be used to grant resources within a namespace. Where a _ClusterRole_ can be used to grant access to cluster scoped resources.
  *NameSpace Resources* `k api-resources namespaced=true`
  - pods/podtemplates
  - roles/bindings
  - jobs
  - events
  - rs/sts/deamonsets
  - services
  - deployments
  - configmaps
  - secrets
  - many more

  *Non-NameSpace Resources* `k api-resources namespaced=false`
  - namespaces
  - nodes
  - apiservices
  - selfsubjectaccess/rules reviews (auth)
  - cluster roles/bindings
  - storage classes
  - volumeattachments
  - webhooks
  - componentstatus
  - and more


**Subjects** The one that will make requests users, service accounts, or groups

**RoleBinding and ClusterRoleBinding** The binding of the Role and Subject

## Default Roles
**view** Readonly access, except secrets
**edit** Can edit most resources, excluding roles and bindings
**admin** Manage roles and bindings at a namespace level
**cluster-admin** God Mode


## Normal Users
**Basic Auth** Auth through the api server using username, password, uid, group
**X.509 client cert** User private key and a CA signing request, it should get certified by the Kube CA
**Bearer Tokens JWT** OpenId Connect on top of OAuth 2.0, or Webhooks
