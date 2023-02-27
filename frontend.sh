source common.sh

print_head "Installing Nginx"
yum install nginx -y &>>${log_file}
echo $?
print_head "Removing the old content"
rm -rf /usr/share/nginx/html/* &>>${log_file}
echo $?
print_head "Downloading the Frontend content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${log_file}
echo $?
print_head "Extracting downloaded Frontend"
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>${log_file}
echo $?

print_head "Copying nginx content for roboshop"
cp ${code_dir}/configs/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${log_file}
echo $?

print_head "Enabling Nginx"
systemctl enable nginx &>>${log_file}
echo $?
print_head "Starting Nginx"
systemctl start nginx &>>${log_file}
echo $?



# if any command is errored or failed we need to stop the script

# Status of command need to be printed