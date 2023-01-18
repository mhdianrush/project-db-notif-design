create database notification_design;

use notification_design;

show tables;

-- user   
create table user (
	id varchar(100) not null,
    name varchar(100) not null,
    primary key (id)
)engine = InnoDB;

show tables;

insert into user(id, name) values('muhammad', 'rush');
insert into user(id, name) values('ian', 'rush');

select * from user;

-- notification 
create table notification (
	id int not null auto_increment,
    title varchar(255) not null,
    detail text not null,
    created_at timestamp not null,
    user_id varchar(100),
    primary key (id)
) engine = InnoDB;
/* user_id diperbolehkan null karena notifikasi yang bersifat global seperti promo nantinya akan otomatis dikirimkan
ke semua user, sehingga nanti user_id nya diperbolehkan null
*/ 
 
show tables;

-- buat foreign key untuk kolom user_id pada tabel notification reference ke kolom id pada tabel user
alter table notification 
add constraint fk_notification_user
foreign key (user_id) references user (id);

describe notification;

insert into notification(title, detail, created_at, user_id) 
values('Contoh Pesanan', 'Detail Pesanan', current_timestamp(), 'ian');

insert into notification(title, detail, created_at, user_id)
values('Contoh Pembayaran', 'Detail Pembayaran', current_timestamp(), 'muhammad');

insert into notification(title, detail, created_at, user_id)
values('Contoh Promo', 'Detail Promo', current_timestamp(), null);

select * from notification;

select * from notification
where (user_id = 'ian' or user_id is null);

-- menampilkan semua notifikasi dari user ian yang diurutkan berdasarkan waktu teratas
select * from notification
where (user_id = 'ian' or user_id is null)
order by created_at desc;

-- menampilkan semua notifikasi dari user muhammad yang diurutkan berdasarkan waktu teratas
select * from notification
where (user_id = 'muhammad' or user_id is null)
order by created_at desc;

-- category
create table category (
	id varchar(100) not null,
    name varchar(100) not null,
    primary key (id)
) engine = InnoDB;

show tables;

alter table notification
add column category_id varchar(100);

describe notification;

alter table notification
add constraint fk_notification_category
foreign key (category_id) references category(id);

desc notification;

select * from notification;

insert into category (id, name) values ('INFO', 'info');
insert into category (id, name) values ('PROMO', 'promo');

select * from category;

select * from notification;

update notification
set category_id = 'INFO'
where id = 1;


update notification
set category_id = 'PROMO'
where id = 2;


update notification
set category_id = 'INFO'
where id = 3;

select * from notification;

-- query untuk menampilkan semua notifikasi yang dimiliki oleh user ian yang diurutkan berdasarkan waktu teratas
select * from notification as n
join category as c 
on (n.category_id = c.id)
where (n.user_id = 'ian' or n.user_id is null)
order by n.created_at desc;

-- query untuk menampilkan semua notifikasi yang dimiliki oleh user muhammad yang diurutkan berdasarkan waktu teratas
select * from notification as n
join category as c 
on (n.category_id = c.id)
where (n.user_id = 'muhammad' or n.user_id is null)
order by n.created_at desc;

-- menampilkan semua notifikasi PROMO pada user muhammad
select * from notification as n
join category as c 
on (n.category_id = c.id)
where (n.user_id = 'muhammad' or n.user_id is null) and c.id = 'PROMO'
order by n.created_at desc;

-- menampilkan semua notifikasi INFO pada user ian
select * from notification as n
join category as c 
on (n.category_id = c.id)
where (n.user_id = 'muhammad' or n.user_id is null) and c.id = 'INFO'
order by n.created_at desc;

-- notification read
create table notification_read (
	id int not null auto_increment,
    is_read boolean not null,
    notification_id int not null,
    user_id varchar(100) not null,
    primary key (id)
) engine = InnoDB;

show tables;

-- membuat foreign key terhadap kolom notification_id pada tabel notification_read
alter table notification_read
add constraint fk_notification_read_notification
foreign key (notification_id) references notification(id);

alter table notification_read
add constraint fk_notification_read_user
foreign key (user_id) references user(id);

describe notification_read;

select * from notification;

-- simulasi terhadap notif yang sudah di-read (misal notif PROMO)
insert into notification_read(is_read, notification_id, user_id) 
values(true, 2, 'ian');

insert into notification_read(is_read, notification_id, user_id)
values(true, 2, 'muhammad');

select * from notification_read;

-- untuk menampilkan kalau sudah di-read
select * from notification as n 
join category as c on (n.category_id = c.id)
left join notification_read as nr on (nr.notification_id = n.id)
where (n.user_id = 'ian' or n.user_id is null) and (nr.user_id = 'ian' or nr.user_id is null)
order by created_at desc;
-- itu pakai left join supaya yang tidak beririsan (belum dibaca) juga pada tabel notification nya ikut ditampilkan 

-- untuk membuktikan nya, akan ditambahkan lagi data nya pada notification:
insert into notification (title, detail, category_id, user_id, created_at)
values('contoh pesanan lagi', 'detail pesanan lagi', 'INFO', 'ian', current_timestamp());

insert into notification (title, detail, category_id, user_id, created_at)
values('contoh promo lagi', 'detail promo lagi', 'PROMO', null, current_timestamp());

select * from notification;

-- untuk menampilkan kalau sudah di-read
select * from notification as n 
join category as c on (n.category_id = c.id)
left join notification_read as nr on (nr.notification_id = n.id)
where (n.user_id = 'ian' or n.user_id is null) and (nr.user_id = 'ian' or nr.user_id is null)
order by created_at desc;
-- itu pakai left join supaya yang tidak beririsan (belum dibaca) juga pada tabel notification nya ikut ditampilkan
-- nah sekarang ada 1 yang sudah dibaca dan 3 yang belum dibaca

-- counter (fitur yang menandakan berapa banyak pesan notifikasi yang belum dibaca)
-- tidak perlu membuat tabel lagi, manfaatkan query read dan unread saja, tapi fokus kepada yang unread

select count(*) 
from notification as n 
join category as c on (n.category_id = c.id)
left join notification_read as nr on (nr.notification_id = n.id)
where (n.user_id = 'ian' or n.user_id is null) and nr.user_id is null
order by created_at desc;

select * from notification;

-- nah sekarang coba tambahkan jumlah yang sudah di-read
insert into notification_read(is_read, notification_id, user_id)
values (true, 4, 'ian');

insert into notification_read(is_read, notification_id, user_id)
values (true, 5, 'ian');

select count(*) 
from notification as n 
join category as c on (n.category_id = c.id)
left join notification_read as nr on (nr.notification_id = n.id)
where (n.user_id = 'ian' or n.user_id is null) and nr.user_id is null
order by created_at desc;