CREATE USER "ota-ce"@"%" IDENTIFIED BY "";

CREATE DATABASE IF NOT EXISTS `treehub`;
GRANT ALL PRIVILEGES ON `treehub`.* TO "ota-ce"@"%";
