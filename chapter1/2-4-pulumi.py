db_instance = aws.rds.Instance(
	"dbInstance",
	allocated_storage=20,
	engine="mysql",
	engine_version="8.0",
	instance_class="db.t3.micro",
	name="mydatabase",
	username="admin",
	password="password",
	db_subnet_group_name="db-subnet-group",
	skip_final_snapshot=True,
)
