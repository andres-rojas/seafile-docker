import sys
from check_init_admin import create_admin

email = str(sys.argv[1])
password = str(sys.argv[2])
create_admin(email, password)
