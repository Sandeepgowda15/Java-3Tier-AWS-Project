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

    set -euo pipefail

    LOG_FILE="/var/log/java-3tier-bootstrap.log"
    exec > >(tee -a "$LOG_FILE") 2>&1

    echo "========================================="
    echo "Java 3-Tier Application Bootstrap Started"
    echo "========================================="

    # --------------------------------------------------
    # 1. Force APT to use IPv4
    # --------------------------------------------------
    echo "Configuring APT for IPv4..."

    echo 'Acquire::ForceIPv4 "true";' \
      > /etc/apt/apt.conf.d/99force-ipv4

    apt-get update -y

    # --------------------------------------------------
    # 2. Install required packages
    # --------------------------------------------------
    echo "Installing required packages..."

    apt-get install -y \
      openjdk-21-jdk \
      python3 \
      curl \
      wget \
      unzip

    echo "Installing AWS CLI..."

    curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
      -o /tmp/awscliv2.zip

    unzip -q /tmp/awscliv2.zip -d /tmp

    /tmp/aws/install

    rm -rf /tmp/aws /tmp/awscliv2.zip

    echo "Java version:"
    java -version

    echo "AWS CLI version:"
    aws --version
    

    # --------------------------------------------------
    # 3. Configure SSM Agent
    # --------------------------------------------------
    echo "Configuring SSM Agent..."

    systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || true
    systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service || true

    # --------------------------------------------------
    # 4. Install Tomcat 11
    # --------------------------------------------------
    echo "Installing Tomcat 11..."

    TOMCAT_VERSION="11.0.26"
    TOMCAT_USER="tomcat11"
    TOMCAT_HOME="/opt/tomcat11"

    if ! id "$TOMCAT_USER" >/dev/null 2>&1; then
      useradd \
        --system \
        --home "$TOMCAT_HOME" \
        --shell /usr/sbin/nologin \
        "$TOMCAT_USER"
    fi

    mkdir -p "$TOMCAT_HOME"

    cd /tmp

    wget -q \
    "https://dlcdn.apache.org/tomcat/tomcat-11/v$${TOMCAT_VERSION}/bin/apache-tomcat-$${TOMCAT_VERSION}.tar.gz" \
     -O tomcat.tar.gz   
   
    tar -xzf tomcat.tar.gz

    rm -rf "$TOMCAT_HOME"

    mv \
      "apache-tomcat-$${TOMCAT_VERSION}" \
      "$TOMCAT_HOME"

    chown -R "$TOMCAT_USER:$TOMCAT_USER" "$TOMCAT_HOME"

    chmod +x "$TOMCAT_HOME"/bin/*.sh

    echo "Tomcat installed at:"
    echo "$TOMCAT_HOME"

    # --------------------------------------------------
    # 5. Create Tomcat configuration directory
    # --------------------------------------------------
    mkdir -p /etc/tomcat11

    # --------------------------------------------------
    # 6. Get RDS credentials from Secrets Manager
    # --------------------------------------------------
    echo "Retrieving RDS credentials from Secrets Manager..."

    SECRET_JSON=$(aws secretsmanager get-secret-value \
      --secret-id "${aws_db_instance.mysql.master_user_secret[0].secret_arn}" \
      --query SecretString \
      --output text)

    DB_PASSWORD=$(printf '%s' "$SECRET_JSON" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
print(data["password"])
')

    DB_USERNAME=$(printf '%s' "$SECRET_JSON" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
print(data["username"])
')

    # --------------------------------------------------
    # 7. Create application database environment
    # --------------------------------------------------
    echo "Creating application database environment..."

    cat > /etc/tomcat11/aws-db.env <<ENVEOF
DB_URL=jdbc:mysql://${aws_db_instance.mysql.address}:3306/${var.database_name}
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
ENVEOF

    chown root:root /etc/tomcat11/aws-db.env
    chmod 600 /etc/tomcat11/aws-db.env

    # --------------------------------------------------
    # 8. Create Tomcat systemd service
    # --------------------------------------------------
    echo "Creating Tomcat systemd service..."

    cat > /etc/systemd/system/tomcat11.service <<SERVICEEOF
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
SERVICEEOF

    mkdir -p /etc/systemd/system/tomcat11.service.d

    cat > /etc/systemd/system/tomcat11.service.d/aws-db.conf <<SERVICEEOF
[Service]
EnvironmentFile=/etc/tomcat11/aws-db.env
SERVICEEOF

    # --------------------------------------------------
    # 9. Download application WAR from S3
    # --------------------------------------------------
    echo "Downloading application WAR from S3..."

    aws s3 cp \
      s3://java-3tier-app-deploy-089783390772/current/javaloginapp.war \
      /tmp/javaloginapp.war

    # --------------------------------------------------
    # 10. Deploy application to Tomcat
    # --------------------------------------------------
    echo "Deploying application..."

    rm -rf "$TOMCAT_HOME/webapps/javaloginapp"
    rm -f "$TOMCAT_HOME/webapps/javaloginapp.war"

    cp \
      /tmp/javaloginapp.war \
      "$TOMCAT_HOME/webapps/javaloginapp.war"

    chown "$TOMCAT_USER:$TOMCAT_USER" \
      "$TOMCAT_HOME/webapps/javaloginapp.war"

    # --------------------------------------------------
    # 11. Start Tomcat
    # --------------------------------------------------
    echo "Starting Tomcat..."

    systemctl daemon-reload
    systemctl enable tomcat11
    systemctl restart tomcat11

    sleep 10

    echo "Tomcat status:"
    systemctl --no-pager status tomcat11 || true

    echo "Port 8080:"
    ss -lntp | grep 8080 || true

    echo "Deployed applications:"
    ls -lh "$TOMCAT_HOME/webapps/"

    echo "========================================="
    echo "Java 3-Tier Application Bootstrap Finished"
    echo "========================================="
  EOF
  )

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

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
