source common.sh

print_head "Set up Mongo DB Repository"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo

print_head "Install MongoDB"
yum install mongodb-org -y

print_head "Update mongodb listen address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

print_head "Enable MongoDB"
systemctl enable mongod

print_head "Start MongoDB"
systemctl restart mongod


