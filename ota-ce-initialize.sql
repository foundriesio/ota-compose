CREATE USER "ota-ce"@"%" IDENTIFIED BY "";

CREATE DATABASE IF NOT EXISTS `treehub`;
GRANT ALL PRIVILEGES ON `treehub`.* TO "ota-ce"@"%";

CREATE DATABASE IF NOT EXISTS `tuf_keyserver`;
GRANT ALL PRIVILEGES ON `tuf_keyserver`.* TO "ota-ce"@"%";

CREATE DATABASE IF NOT EXISTS `tuf_reposerver`;
GRANT ALL PRIVILEGES ON `tuf_reposerver`.* TO "ota-ce"@"%";

CREATE DATABASE IF NOT EXISTS `director`;
GRANT ALL PRIVILEGES ON `director`.* TO "ota-ce"@"%";
