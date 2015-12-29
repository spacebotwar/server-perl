create database sbw;
grant all privileges on sbw.* to 'sbw'@'%' with GRANT OPTION;
use sbw;

create table user (
    id          int(11) not null auto_increment,
    username    varchar(30) not null,
    password    varchar(45) not null,
    email       varchar(255) default null,
    password_recovery_key   varchar(45) default null,
    primary key (id),
    key idx_password_recovery_key (password_recovery_key)
) engine=InnoDB default charset=utf8;

insert into user set id=1, username='icydee', password='{SSHA}X/vOZJqzuIOLJTGD8i9R/cDYsuo3osPR', email='sbw@icydee.com';


create table league (
    id          int(11) not null auto_increment,
    name        varchar(40) not null,
    parent      int(11),
    primary key (id),
    key idx_league_name_key (name)
) engine=InnoDB default charset=utf8;

insert into league set id=1, name='Premier', parent=1;
insert into league set id=2, name='England', parent=1;
insert into league set id=3, name='USA', parent=1;
insert into league set id=4, name='Australia', parent=1;
insert into league set id=5, name='Brazil', parent=1;


create table competition (
    id          int(11) not null auto_increment,
    program_a   int(11) not null,
    program_b   int(11) not null,
    points_a    int(11) not null default 0,
    points_b    int(11) not null default 0,
    status      varchar(20) not null default 'prematch',
    time_a      int(11) not null default 0,
    time_b      int(11) not null default 0,
    match_time  datetime,
    primary key (id)
) engine=InnoDB default charset=utf8;

create table code_store (
    id          int(11) not null auto_increment,
    name        varchar(45) not null,
    title       varchar(256) not null default "",
    description varchar(1024) not null default "",
    owner_id    int(11) not null,
    code        text(65500) not null default "",
    parent_id   int(11) not null,
    primary key (id)
) engine=InnoDB default charset=utf8;

insert into code_store (id,name,title,description,owner_id,code,parent_id)
    values (1,'genesis','genesis','first one',1,'',0);

