-- Projet 01 : schéma de la base (à exécuter une fois, depuis le bastion ou une instance Tomcat)
--   mysql -h <endpoint-rds> -u admin -p < db/schema.sql
CREATE DATABASE IF NOT EXISTS UserDB;
USE UserDB;
CREATE TABLE IF NOT EXISTS Employee (
  id int unsigned auto_increment not null,
  first_name varchar(250),
  last_name varchar(250),
  email varchar(250),
  username varchar(250),
  password varchar(250),
  regdate timestamp,
  primary key (id)
);
