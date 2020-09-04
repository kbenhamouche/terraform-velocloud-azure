# terraform-velocloud-azure

Deploy a VeloCloud Edge on Azure via Terraform.

This example is for DEMO purpose ONLY

Before to execute the "tfapply.sh" script, you have to provide the following requirements:

1- Create an Edge profile and configuration on Velocloud Orchestrator (VCO),

2- Provide the Activation Code AND the VCO address in the "cloud-init" file,

3- Customize the Azure parameters in the terraform variable file, Note: I assume that your Azure credentials already exists in your home directory

4- (Optional): You can execute the following command: ./find-ami.sh "VeloCloud VCE" to list the lastest VeloCloud AMI per region. Then, you can update the terraform variable file with the "find-ami.sh" output.

To connect to the VeloCloud Edge via SSH, the private key will provide at the end of "tfapply.sh" execution. copy the private key in a file named "vce.pem".

To destroy the VeloCloud Edge and the environment, execute the "tfdestroy.sh" script.

Finally, every time you create or recreate the VeloCloud, you have to create a new Edge config in VCO to get the new Activation Code OR you can do a RMA and generate the new Activation Code (I will "maybe" automate this part)

Enjoy !
