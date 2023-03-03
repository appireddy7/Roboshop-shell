source common.sh

roboshop_app_password=$1
if [ -z "${roboshop_app_password}"  ]; then
  echo -e "\e[31mMissing Roboshop App user password argument\e[0m"
  exit 1
  fi

print_head "Setup Erlang Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>>${log_file}
status_check $?

print_head "Setup RabbitMQ Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>${log_file}
status_check $?

print_head "Install Erlang & RabbitMQ"
yum install rabbitmq-server erlang -y &>>${log_file}
status_check $?

print_head "Enable RabbitMQ service"
systemctl enable rabbitmq-server &>>${log_file}
status_check $?

print_head "Start RabbitMQ service"
systemctl start rabbitmq-server &>>${log_file}
status_check $?

print_head "Add Application user"
rabbitmqctl add_user roboshop ${roboshop_app_password} &>>${log_file}
status_check $?


print_head "Configure Permission for App user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"