# Prometheus and Grafana installation in k8s behind nginx with secrets in Vault. Ah, and flask app also 8-)

Hi all! 
Not so many time ago I had decided to spin up such as stack of services:

    / Installs and configures NGINX, Grafana, Prometheus
    / Installs and configures your custom written simple web application in Python 3
    / Configures NGINX as a reverse proxy that exposes a following locations:
    + "/app" – exposes your web app and displays web page visit counter (the counter can
    reset on application restart)
    + "/health" – exposes custom application metrics for Prometheus scraper, the metrics
    should be:
    * The aforementioned mentioned page visit counter
    * Current application's CPU utilization
    * Current application's RAM utilization
    o + "/grafana" – exposes the default Grafana web interface, which requires user
    authentication
    o + "/grafana/dashboard" – exposes read-only Grafana dashboard displaying
    your web app's custom metrics over time, no user authentication should be
    required to access it
    
    - Please store application passwords in Ansible vault (the master password can be stored in clear
    text form in the repo)
    - Please harden a system's security with firewall and SELinux
    - Please ensure all services are up and running even after box reboot

To proceed with my code,  you need to first of all ensure, that you have terraform installed:

    $ terraform -version
    Terraform v1.2.5
and AWS credentials established:

    $ cat ~/.aws/credentials 
    [default]
    aws_access_key_id=xxxxxxxxxxxx
    aws_secret_access_key=xxxxxxxxxxxxxxx

If everything is ok, there is no reason to avoid to 
clone the repo 8-) like that:

    git clone https://github.com/maxrodkin/tf-k8s-helm-nginx-prometheus-grafana-flask.git \
    && cd tf-k8s-helm-nginx-prometheus-grafana-flask

and also, you have to create the variables file for the Terraform, for example:

    $ cat default.tfvars 
    vpc_id = "vpc-YOURs"
    subnet_id = "subnet-YOURs"
    security_group_id = "sg-YOURs"
    ami = "SOME UBUNTU AMI"
    key_name = "key_name-YOURs"
    region = "us-east-1 or -YOURs 8-)"
    aws_profile = "default"

please replace the "-YOURs" signature with your meangfull values 8-)
I assume that you have already vpc_id, subnet_id, security_group_id ... under your hand.
It seems that all are ready to make this alive! 

    terraform init && \
    terraform plan -var-file=default.tfvars && \ 
    terraform apply -var-file=default.tfvars -auto-approve
No more then in 1 minute you will get the answer:

    ...
    aws_instance.k8s: Still creating... [40s elapsed]
    aws_instance.k8s: Creation complete after 42s [id=i-0c6385951d91b166b]
    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    Outputs:
    ec2instance = "ec2-xx-xx-xx-xx.compute-1.amazonaws.com"

and it`s almost done! Ah, wait please 2 mins to let the cloud-init script to finish the installation. And you can use next table as a hint to check your new envoirenment:

|app|[http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:30010/app](http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:30010/app)|
|grafana|[http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:30010/grafana/](http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:30010/grafana/)|
|health|[http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:30010/health](http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:30010/health)|
|ssh|ssh -i key_name-YOURs.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com |

If something goes wrong, you can check the log of cloud-init script. In a normal case of installation it finished as (similar):

    # tail /var/log/cloud-init-output.log
    policies             ["root"]
    Success! Enabled the kv secrets engine at: secret/
    Success! Data written to: secret/grafana
    ====== Data ======
    Key         Value
    ---         -----
    password    P@ssw0rd_1
    username    admin
    Cloud-init v. 22.2-0ubuntu1~20.04.1 running 'modules:final' at Fri, 22 Jul 2022 14:11:47 +0000. Up 24.37 seconds.
    Cloud-init v. 22.2-0ubuntu1~20.04.1 finished at Fri, 22 Jul 2022 14:16:11 +0000. Datasource DataSourceEc2Local.  Up 288.22 seconds

## Enjoy it!

## Things to do:  
    / instead nginx-standalone ingress the ingress-nginx deployment should be used  
    / should replace the ""sleep"" to asynchronous loop in:  
        * ./nginx-standalone.conf/nginx-standalone-install.sh:sleep 15  
        * ./vault-install.sh:sleep 15  
        * ./prometheus-grafana-install.sh:sleep 15  
        * ./flask-install.sh:sleep 10  
    / should replace the github.com/maxrodkin/ingress-nginx source to original one with parameters or customisation  