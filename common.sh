code_dir=$(pwd)
log_file=/tmp/roboshop.log
rm -f ${log_file}

print_head() {
  echo -e "\e[36m$1\e[0m"
}

status_check() {
if [ $1 -eq 0 ]; then
   echo SUCCESS
else
   echo FAILURE
   echo "Read the log file ${log_file} for more information about the error"
fi
}

systemd_setup() {
  print_head "Copy systemD service File"
  cp ${code_dir}/configs/${component}.service /etc/systemd/system/${component}.service &>>${log_file}
  status_check $?

  print_head "Reload SystemD"
  systemctl daemon-reload &>>${log_file}
  status_check $?

  print_head "Enable ${component} service"
  systemctl enable ${component} &>>${log_file}
  status_check $?

  print_head "Start ${component} service"
  systemctl restart ${component} &>>${log_file}
  status_check $?
}

schema_setup() {
  if [ "${schema_type}" == "mongo" ]; then
  print_head "Copying mongodb Repo file"
  cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
  status_check $?

  print_head "Installing MongoDb org shell"
  yum install mongodb-org-shell -y &>>${log_file}
  status_check $?

  print_head "Loading Schema"
  mongo --host mongodb.devopsar.online </app/schema/${component}.js &>>${log_file}
  status_check $?

  elif [ "${schema_type}" == "mysql" ];then
  print_head "Install MYSQL Client"
  yum install mysql -y &>>${log_file}
  status_check $?
  print_head "Loading Schema"
  mysql -h mysql.devopsar.online -uroot -p${mysql_root_password} < /app/schema/shipping.sql &>>${log_file}
  status_check $?
  fi
}

app_prepreq_setup() {
  print_head "Create Roboshop user"
  id roboshop &>>${log_file}
  if [ $? -ne 0 ]; then
  useradd roboshop &>>${log_file}
  fi
  status_check $?

  print_head "Create Application Directory"
  if [ ! -d /app ]; then
  mkdir /app &>>${log_file}
  fi
  status_check $?

  print_head "Delete old content"
  rm -rf /app/* &>>${log_file}
  status_check $?

  print_head "Downloading app content"
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log_file}
  cd /app
  status_check $?

  print_head "Extracting App Content"
  unzip /tmp/${component}.zip &>>${log_file}
  status_check $?
}
nodejs() {

print_head "Configure Node JS Repo"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
status_check $?

print_head "Install Node JS"
yum install nodejs -y &>>${log_file}
status_check $?

app_prepreq_setup

print_head "Installing NodeJS dependencies "
npm install &>>${log_file}
status_check $?

schema_setup

systemd_setup

}

java() {
  print_head "Install Maven"
  yum install maven -y &>>${log_file}
  status_check $?

### Application Prereq Setup Function ####
app_prepreq_setup

print_head "Download dependencies & Package"
  mvn clean package &>>${log_file}
  mv target/${component}-1.0.jar ${component}.jar &>>${log_file}
  status_check $?

### Schema Setup Function ###
 schema_setup

###  SystemD function ###
 systemd_setup


  }