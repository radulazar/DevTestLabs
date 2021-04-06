# DevTestLabs

A set of ARM templates to deploy a dev&test environment made of
 - a virtual network with 3 subnets. If multiple environments are created, vnet scopes are overlapping. 
 - a set of virtual machines connected to the same subnet in the vnet. The VMs are based on custom images hosted in an Azure Shared Gallery. The list of VMs is collected from vmlist.csv file. VM's IP: 10.0.0.<VMIndex from vmlist.csv>. 
 - multiple environments have   
 - each environment name: new-guid()
 - a private link & private endpoint is created from an existing vnet to each VM from each environment. A load balancer is put in front of each environment (cannot put a private link directly into a vnet, it requires a PaaS service or load balancer)
 ![alt text](https://github.com/radulazar/DevTestLabs/blob/main/img/DevBox.jpg?raw=true text)