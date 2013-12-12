drop table if exists user;

create table user (
    id          int(11) not null auto_increment,
    name        varchar(30) not null,
    password    varchar(45) not null,
    email       varchar(255) default null,
    password_recovery_key   varchar(45) default null,
    primary key (id),
    key idx_password_recovery_key (password_recovery_key)
) engine=InnoDB default charset=utf8;

insert into user set id=1, name='icydee', password='{SSHA}X/vOZJqzuIOLJTGD8i9R/cDYsuo3osPR', email='sbw@icydee.com';

