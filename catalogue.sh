source common.sh

print_head "Configure Node JS Repo"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
status_check $?
print_head "Install Node JS"
yum install nodejs -y &>>${log_file}
status_check $?
print_head "Create Roboshop user"
id roboshop &>>${log_file}
if [ $? -ne 0 ]; then
useradd roboshop &>>${log_file}
fi
status_check $?

print_head "Create Application Directory"
if [ ! -d /app ]; then
mkdir /app &>>${log_file
fi
status_check $?

print_head "Delete old content"
rm -rf /app/* &>>${log_file}
status_check $?
print_head "Downloading app content"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${log_file}
cd /app

print_head "Extracting App Content"
unzip /tmp/catalogue.zip &>>${log_file}
status_check $?

print_head "Installing NodeJS dependencies "
npm install &>>${log_file}
status_check $?
print_head "Copy systemD service File"
cp ${code_dir}/configs/catalogue.service /etc/systemd/system/catalogue.service &>>${log_file}
status_check $?
print_head "Reload SystemD"
systemctl daemon-reload &>>${log_file}
status_check $?
print_head "Enable catalogue service"
systemctl enable catalogue &>>${log_file}
status_check $?
print_head "Start catalogue service"
systemctl restart catalogue &>>${log_file}
status_check $?

print_head "Copying mongodb Repo file"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
status_check $?
print_head "Installing MongoDb org shell"
yum install mongodb-org-shell -y &>>${log_file}
status_check $?
print_head "Loading Schema"
mongo --host mongodb.devopsar.online </app/schema/catalogue.js &>>${log_file}
status_check $?