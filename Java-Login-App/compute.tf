data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


resource "aws_launch_template" "app" {

  name = "${var.project_name}-app-lt"

  image_id = data.aws_ami.ubuntu.id

  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.app_ec2_profile.name
  }

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]


  user_data = base64encode(<<-EOF
    #!/bin/bash

    set -e

    echo "===== Starting Java 3-Tier EC2 bootstrap ====="

    
    # Force IPv4 for APT
    
    echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4


    
    # Update packages

    apt-get update -y


    # Install required packages
    
    apt-get install -y \
      openjdk-21-jdk \
      awscli \
      python3 \
      curl \
      wget \
      unzip


    
    # Start SSM Agent
    

    snap start amazon-ssm-agent || true

    systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || true


    
    # Create Tomcat user
    

    if ! id tomcat11 >/dev/null 2>&1; then
      useradd \
        --system \
        --home /opt/tomcat11 \
        --shell /usr/sbin/nologin \
        tomcat11
    fi


    
    # Download Tomcat 11
    

    cd /tmp

    wget -q \
      https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.26/bin/apache-tomcat-11.0.26.tar.gz \
      -O tomcat11.tar.gz


    
    # Install Tomcat
    

    rm -rf /opt/tomcat11

    tar -xzf tomcat11.tar.gz \
      -C /opt

    mv /opt/apache-tomcat-11.0.26 /opt/tomcat11

    chown -R tomcat11:tomcat11 /opt/tomcat11


    # --------------------------------------------------
    # Create Tomcat environment directory
    # --------------------------------------------------

    mkdir -p /etc/tomcat11

    chmod 750 /etc/tomcat11


    # --------------------------------------------------
    # Retrieve RDS credentials from Secrets Manager
    # --------------------------------------------------

    SECRET_JSON=$(aws secretsmanager get-secret-value \
      --secret-id "${aws_db_instance.mysql.master_user_secret[0].secret_arn}" \
      --region ${var.aws_region} \
      --query SecretString \
      --output text)


    DB_PASSWORD=$(echo "$SECRET_JSON" | \
      python3 -c 'import sys,json; print(json.load(sys.stdin)["password"])')


    DB_USERNAME=$(echo "$SECRET_JSON" | \
      python3 -c 'import sys,json; print(json.load(sys.stdin)["username"])')


    # --------------------------------------------------
    # Create Tomcat database environment file
    # --------------------------------------------------

    cat > /etc/tomcat11/aws-db.env <<ENVFILE
DB_URL=jdbc:mysql://${aws_db_instance.mysql.address}:3306/${var.database_name}
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
ENVFILE


    chmod 600 /etc/tomcat11/aws-db.env

    chown root:root /etc/tomcat11/aws-db.env


    # --------------------------------------------------
    # Create Tomcat systemd service
    # --------------------------------------------------

    cat > /etc/systemd/system/tomcat11.service <<'SERVICEFILE'
[Unit]
Description=Apache Tomcat 11 Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat11
Group=tomcat11

Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64"
Environment="CATALINA_HOME=/opt/tomcat11"
Environment="CATALINA_BASE=/opt/tomcat11"
Environment="CATALINA_PID=/opt/tomcat11/temp/tomcat.pid"

ExecStart=/opt/tomcat11/bin/startup.sh
ExecStop=/opt/tomcat11/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICEFILE


    # --------------------------------------------------
    # Connect database environment to Tomcat
    # --------------------------------------------------

    mkdir -p /etc/systemd/system/tomcat11.service.d

    cat > /etc/systemd/system/tomcat11.service.d/aws-db.conf <<'SERVICECONF'
[Service]
EnvironmentFile=/etc/tomcat11/aws-db.env
SERVICECONF


    # --------------------------------------------------
    # Download application WAR from S3
    # --------------------------------------------------

    aws s3 cp \
      s3://java-3tier-app-deploy-089783390772/javaloginapp-0.0.1-SNAPSHOT.war \
      /tmp/javaloginapp.war \
      --region ${var.aws_region}


    # --------------------------------------------------
    # Deploy application
    # --------------------------------------------------

    rm -rf /opt/tomcat11/webapps/javaloginapp
    rm -f /opt/tomcat11/webapps/javaloginapp.war

    cp /tmp/javaloginapp.war \
      /opt/tomcat11/webapps/javaloginapp.war

    chown tomcat11:tomcat11 \
      /opt/tomcat11/webapps/javaloginapp.war


    # --------------------------------------------------
    # Start Tomcat
    # --------------------------------------------------

    systemctl daemon-reload

    systemctl enable tomcat11

    systemctl start tomcat11


    # --------------------------------------------------
    # Bootstrap complete
    # --------------------------------------------------

    echo "===== Java 3-Tier EC2 bootstrap completed ====="

    java -version

  EOF
  )


  # --------------------------------------------------
  # Root volume
  # --------------------------------------------------

  block_device_mappings {

    device_name = "/dev/sda1"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }


  # --------------------------------------------------
  # Instance tags
  # --------------------------------------------------

  tag_specifications {

    resource_type = "instance"

    tags = {
      Name    = "${var.project_name}-app"
      Project = var.project_name
      Tier    = "application"
    }
  }


  tags = {
    Name    = "${var.project_name}-app-lt"
    Project = var.project_name
    Tier    = "application"
  }
}
