# Bicep Deployment Stacks

Learning deployment stacks...

## About

Deployment stacks in Bicep is an alternate method of declaratively deploying resources via Bicep infrastructure-as-code templates.

See [MS Learn](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks?tabs=azure-powershell) for more information and [quickstart](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/quickstart-create-deployment-stacks?tabs=azure-cli%2CCLI) for getting started.

## Example

To demonstrate deployment stacks the following file [main.bicep](./main.bicep) will be used as an example.

It contains ...

## Limitations

- No [what-if](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if) support (yet): no method for previewing your changes prior to updating a stack (equivalent to a `terraform plan` operation). This is perhaps the biggest limitation to wide adoption for this method of deployment.

## Prerequisites

- An Azure account with an active subscription
- Azure CLI version 2.61.0 or later.
- Visual Studio Code with the Bicep extension.

## Commands

Note: all commands assume subscription scope. For equivalents for other scopes, see the [docs](https://learn.microsoft.com/en-us/cli/azure/stack?view=azure-cli-latest).

### Important flags

- **`action-on-unmanage`**: switch to define what happens to resources that are no longer managed after a stack is updated or deleted. Allowed values are:
  - `deleteAll`: use delete rather than detach for managed resources and resource groups.
  - `deleteResources`: use delete rather than detach for managed resources only.
  - `detachAll`: detach the managed resources and resource groups.
- **`deny-settings-mode`**: Defines the operations that are prohibited on the managed resources to safeguard against unauthorized security principals attempting to delete or update them. This restriction applies to everyone unless explicitly granted access. The values include: 
  - `none`: Does not enforce any deny settings
  - `denyDelete`: Enforces deny on delete operations
  - `denyWriteAndDelete`: Enforces deny on write and delete operations

#### Other flags

- `deny-settings-apply-to-child-scopes`: When specified, the deny setting mode configuration also applies to the child scope of the managed resources
- `deny-settings-excluded-actions`: List of role-based access control (RBAC) management operations excluded from the deny settings. Up to 200 actions are allowed.
- `deny-settings-excluded-principals`: List of Microsoft Entra principal IDs excluded from the lock. Up to five principals are allowed.

### Create stack

```bash
az stack sub create \
  --name '<deployment-stack-name>' \
  --location '<location>' \
  --template-file '<bicep-file-name>' \
  --action-on-unmanage 'detachAll' \
  --deny-settings-mode 'none'
```

### List stacks

```bash
az stack sub list
```

### Update stack

```bash
az stack sub create \
  --name '<deployment-stack-name>' \
  --location '<location>' \
  --template-file '<bicep-file-name>' \
  --action-on-unmanage 'detachAll' \
  --deny-settings-mode 'none'
```

## Demo

1. Create the stack:

```bash
az stack sub create --name demo-stack --location westeurope --template-file main.bicep --action-on-unmanage 'deleteAll' --deny-settings-mode 'denyDelete'
```

2. Try to remove `subnet2` via the portal
    1. Navigate to the deployed virtual network
    2. Select **Subnets** in the side menu
    3. Highlight `subnet2` and select **Delete**

This should invoke a denied action ("Failed to delete subnet") due to the deny lock created by the deployment stack.

2. Edit [`resources.bicep`](./resources.bicep) to comment out the `subnet2` resource via a deployment stack update.

```diff
+ // resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
+ //  name: 'subnet2'
+ //  parent: virtualNetwork
+ //  properties: {
+ //    addressPrefix: '10.0.1.0/24'
+ //  }
+ // }
```

and run the command:

```bash
az stack sub create --name demo-stack --location westeurope --template-file main.bicep --action-on-unmanage 'deleteAll' --deny-settings-mode 'denyDelete'
```

Validate the command with `y` after running

3. Verify that the subnet has been removed in the portal :white_check_mark: