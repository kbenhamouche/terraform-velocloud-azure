// Create Resource Group
resource "azurerm_resource_group" "velo-demo-rg" { 
    name = "vcn-demo-rg"
    location = var.azure_region
}
// create VNET
resource "azurerm_virtual_network" "velo-vnet" {
    name = "vcn-demo-vnet"
    resource_group_name = azurerm_resource_group.velo-demo-rg.name
    location = azurerm_resource_group.velo-demo-rg.location
    address_space = [var.vnet_cidr_block]
}

// define public subnet
resource "azurerm_subnet" "velo-public-sn" {
    name = "vcn-public-sn"
    resource_group_name = azurerm_resource_group.velo-demo-rg.name
    virtual_network_name = azurerm_virtual_network.velo-vnet.name 
    address_prefixes = [var.public_sn_cidr_block]
}

// define private subnet
resource "azurerm_subnet" "velo-private-sn" {
    name = "vcn-private-sn"
    resource_group_name = azurerm_resource_group.velo-demo-rg.name
    virtual_network_name = azurerm_virtual_network.velo-vnet.name 
    address_prefixes = [var.private_sn_cidr_block]
}

// Allocation public IP
resource "azurerm_public_ip" "velo-pubip" {
    name = "velo-pubip"
    location = var.azure_region
    resource_group_name = azurerm_resource_group.velo-demo-rg.name
    allocation_method = "Static"
    tags = {
        environment = "velo-pubip"
    }
}

// Create Routing table for public access
resource "azurerm_route_table" "velo-public-rt" {
    name = "vcn-public-rt"
    location = azurerm_resource_group.velo-demo-rg.location 
    resource_group_name = azurerm_resource_group.velo-demo-rg.name
}

// Associate public route table to subnet
resource "azurerm_subnet_route_table_association" "public2rt" {
  subnet_id = azurerm_subnet.velo-public-sn.id
  route_table_id = azurerm_route_table.velo-public-rt.id
}

// Configure default route
resource "azurerm_route" "default-route" {
    name = "default-route"
    resource_group_name = azurerm_resource_group.velo-demo-rg.name 
    route_table_name = azurerm_route_table.velo-public-rt.name
    address_prefix = "0.0.0.0/0"
    next_hop_type = "Internet"
}

// Create Routing table for private access
resource "azurerm_route_table" "velo-private-rt" {
    name = "vcn-private-rt"
    location = azurerm_resource_group.velo-demo-rg.location 
    resource_group_name = azurerm_resource_group.velo-demo-rg.name
}

// Associate private route table to subnet
resource "azurerm_subnet_route_table_association" "private2rt" {
  subnet_id = azurerm_subnet.velo-private-sn.id
  route_table_id = azurerm_route_table.velo-private-rt.id
}

// define security group for LAN interface
resource "azurerm_network_security_group" "velo-sg-lan" {
  name = "velo-sg-lan"
  location = azurerm_resource_group.velo-demo-rg.location
  resource_group_name = azurerm_resource_group.velo-demo-rg.name
  security_rule {
    name = "AllowALL"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "velo-sg-lan"
  }
}

// define security group for WAN interface
resource "azurerm_network_security_group" "velo-sg-wan" {
  name = "velo-sg-wan"
  location = azurerm_resource_group.velo-demo-rg.location
  resource_group_name = azurerm_resource_group.velo-demo-rg.name
  security_rule {
    name = "AllowSSH"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "AllowVCMP"
    priority = 101
    direction = "Inbound"
    access = "Allow"
    protocol = "Udp"
    source_port_range = "*"
    destination_port_range = "2426"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "velo-sg-wan"
  }
}

// GE1 definition - Management interface
resource "azurerm_network_interface" "velo-ge1" {
    name = "velo-ge1"
    location = azurerm_resource_group.velo-demo-rg.location 
    resource_group_name = azurerm_resource_group.velo-demo-rg.name 
    enable_ip_forwarding = true
    ip_configuration {
        name = "velo-ge1-ip"
        subnet_id = azurerm_subnet.velo-public-sn.id
        private_ip_address_allocation = "Dynamic"
    }
    tags = {
        environment = "velo-ge1"
    } 
}

// GE2 definition - WAN interface
resource "azurerm_network_interface" "velo-ge2" {
    name = "velo-ge2"
    location = azurerm_resource_group.velo-demo-rg.location 
    resource_group_name = azurerm_resource_group.velo-demo-rg.name 
    enable_ip_forwarding = true
    ip_configuration {
        name = "velo-ge2-ip"
        subnet_id = azurerm_subnet.velo-public-sn.id
        private_ip_address_allocation = "Static"
        private_ip_address = var.public_ip
        public_ip_address_id = azurerm_public_ip.velo-pubip.id
    }
    tags = {
        environment = "velo-ge2"
    } 
}

// GE3 definition - LAN interface
resource "azurerm_network_interface" "velo-ge3" {
    name = "velo-ge3"
    location = azurerm_resource_group.velo-demo-rg.location 
    resource_group_name = azurerm_resource_group.velo-demo-rg.name 
    enable_ip_forwarding = true
    ip_configuration {
        name = "velo-ge3-ip"
        subnet_id = azurerm_subnet.velo-private-sn.id
        private_ip_address_allocation = "Static"
        private_ip_address = var.private_ip 
    }
    tags = {
        environment = "velo-ge3"
    } 
}

// Associate NSG to interfaces
resource "azurerm_network_interface_security_group_association" "sg-lan-ge1" {
  network_interface_id = azurerm_network_interface.velo-ge1.id
  network_security_group_id = azurerm_network_security_group.velo-sg-lan.id
}

resource "azurerm_network_interface_security_group_association" "sg-lan-ge3" {
  network_interface_id = azurerm_network_interface.velo-ge3.id
  network_security_group_id = azurerm_network_security_group.velo-sg-lan.id
}

resource "azurerm_network_interface_security_group_association" "sg-wan-ge2" {
  network_interface_id = azurerm_network_interface.velo-ge2.id
  network_security_group_id = azurerm_network_security_group.velo-sg-wan.id
}

// key pair creation
resource "tls_private_key" "velo-key" {
  algorithm = "RSA"
}

resource "azurerm_virtual_machine" "velo-vedge" {
    name = "velo-vedge"
    location = azurerm_resource_group.velo-demo-rg.location 
    resource_group_name = azurerm_resource_group.velo-demo-rg.name
    network_interface_ids = [azurerm_network_interface.velo-ge1.id,azurerm_network_interface.velo-ge2.id,azurerm_network_interface.velo-ge3.id]
    vm_size = var.instance_type 
    delete_os_disk_on_termination = true 
    delete_data_disks_on_termination = true 
    primary_network_interface_id = azurerm_network_interface.velo-ge2.id
    
    storage_image_reference {
        publisher = "velocloud"
        offer = "velocloud-virtual-edge-3x"
        sku = "velocloud-virtual-edge-3x"
        version = "3.3.2"
    }

    plan {
        name = "velocloud-virtual-edge-3x"
        publisher = "velocloud"
        product = "velocloud-virtual-edge-3x"
    }

    storage_os_disk {
        name = "velo-disk"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    
    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path = "/home/vce/.ssh/authorized_keys"
            key_data = tls_private_key.velo-key.public_key_openssh
        }
    }
    
    os_profile {
        computer_name  = "velo-vce"
        admin_username = var.vce_username
        custom_data = file("cloud-init")
    }
    
    tags = {
        environment = "production"
    }
}

// Static route for branch (example)
resource "azurerm_route" "branch_route" {
    name = "branch-route"
    resource_group_name = azurerm_resource_group.velo-demo-rg.name 
    route_table_name = azurerm_route_table.velo-private-rt.name
    address_prefix = "10.5.99.0/24"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = var.private_ip
}