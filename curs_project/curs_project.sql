/*
Курсовой проект. Армен Амирханян, студент geekbrains.

В курсовом проекте предложена реализация БД для сайта angel.co.
Суть сайта — база данных венчурных фондов, стартапов, инвесторов, и фаундеров стартапов.


БД состоит из следующих таблиц:

company — компания. Может быть либо стартапом, либо венчурным фондом, о чем говорит индикатор isfund
company_investment — инвестиции фонда или стартапы. В какие стартапы или фонды он сделал инвестиции.
city - таблица городов в привязке к стране
country - таблица стран
market - рынки, на которых работает компания. Например, artifical intelligence
company_market - таблица, связывающая рынки и компании. У компании может быть несколько рынков.
person — таблица инвесторов и фаундеров стартапов
person_education - таблица, отражающая какие вузы закончил человек
person_investments - таблица, содержащая список компании, в которые инвестировал инвестор
university - список университетов, которые закончил человек

Комментарии к полям даны в комментариях при создании таблиц

БД заполнена случайными данными, сгенерированными сервисом filldb.info


Файл с ERDiagram представлен в файле erdiagram.png (взят из DBeaver)

В sql представлены следующие характерные выборки (написаны после скриптов создания и наполнения таблиц):
---------------------
Группировки и JOIN:

sort_markets_by_popularity - вывести список рынков с указанием количества компаний, которые на них сфокусированы

show_total_investments_of_company - вывести общую сумму инвестиций в каждую компанию

Вложенные запросы:

show_co_investors Для заданного фонда вывести список фондов, которые вместе с ним инвестировали в компании

Представления:

full_person_info - подробная информация о пользователях, где прямо указаны город и страна

full_startup_invested_info - подробная справка о стартапах/ фондах, в которые есть хоть одна инвестиция, где указана
сумма инвестиций от частных инвесторов,
сумма инвестиций от фондов


Хранимые триггеры:

on_insert_company_investments_update_raised При добавлении новой инвестиции в company_investments
автоматически меняется значение raised у стартапа

on_delete_company_investments_update_raised При удалении инвестиции в company_investments автоматически меняется значение
raised у стартапа, у кого убрали инвестицию

Процедуры:

repair_raised - установим правильное значение raised у всех компаний. Под правильным
понимается сумма инвестиций от других компаний.



*/
drop database if exists curs_project;
create database curs_project;
use curs_project;
CREATE TABLE `company` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` varchar(100) NOT NULL,
	`about` TEXT,
	`company_size` INT,
	`raised` INT,
	`website` varchar(255),
	`twitter` varchar(255),
	`facebook` varchar(255),
	`city_id` INT NOT NULL,
	`isfund` BOOLEAN NOT NULL DEFAULT False,
	PRIMARY KEY (`id`),
  INDEX (`name`)
);

CREATE TABLE `company_investment` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`investor_id` INT NOT NULL,
	`investment_id` INT NOT NULL,
	`amount` INT NOT NULL,
	`date_invested` DATE NOT NULL,
	PRIMARY KEY (`id`),
  INDEX (`investor_id`)
);

CREATE TABLE `city` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` varchar(255) NOT NULL,
	`country_id` INT NOT NULL,
	PRIMARY KEY (`id`),
  INDEX (`name`)
);

CREATE TABLE `country` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` varchar(255) NOT NULL UNIQUE,
	PRIMARY KEY (`id`)
);

CREATE TABLE `market` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` varchar(255) NOT NULL UNIQUE,
	PRIMARY KEY (`id`)
);

CREATE TABLE `company_market` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`company_id` INT NOT NULL,
	`market_id` INT NOT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE `person` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`firstname` varchar(255) NOT NULL,
	`lastname` varchar(255) NOT NULL,
	`city_id` INT NOT NULL,
	`isinvestor` BOOLEAN NOT NULL DEFAULT False,
	`facebook` varchar(255) NOT NULL,
	`about` TEXT,
	PRIMARY KEY (`id`)
);

CREATE TABLE `person_education` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`university_id` INT NOT NULL,
	`person_id` INT NOT NULL,
	`graduate` DATE NOT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE `person_investments` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`person_id` INT NOT NULL,
	`company_id` INT NOT NULL,
	`amount` INT NOT NULL,
	`date_invested` DATE NOT NULL,
	PRIMARY KEY (`id`),
  INDEX (`person_id`)
);

CREATE TABLE `university` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` varchar(255) NOT NULL,
	`city` INT NOT NULL,
	PRIMARY KEY (`id`)
);

ALTER TABLE `company` ADD CONSTRAINT `company_fk0` FOREIGN KEY (`city_id`) REFERENCES `city`(`id`);

ALTER TABLE `company_investment` ADD CONSTRAINT `company_investment_fk0` FOREIGN KEY (`investor_id`) REFERENCES `company`(`id`);

ALTER TABLE `company_investment` ADD CONSTRAINT `company_investment_fk1` FOREIGN KEY (`investment_id`) REFERENCES `company`(`id`);

ALTER TABLE `city` ADD CONSTRAINT `city_fk0` FOREIGN KEY (`country_id`) REFERENCES `country`(`id`);

ALTER TABLE `company_market` ADD CONSTRAINT `company_market_fk0` FOREIGN KEY (`company_id`) REFERENCES `company`(`id`);

ALTER TABLE `company_market` ADD CONSTRAINT `company_market_fk1` FOREIGN KEY (`market_id`) REFERENCES `market`(`id`);

ALTER TABLE `person` ADD CONSTRAINT `person_fk0` FOREIGN KEY (`city_id`) REFERENCES `city`(`id`);

ALTER TABLE `person_education` ADD CONSTRAINT `person_education_fk0` FOREIGN KEY (`university_id`) REFERENCES `university`(`id`);

ALTER TABLE `person_education` ADD CONSTRAINT `person_education_fk1` FOREIGN KEY (`person_id`) REFERENCES `person`(`id`);


ALTER TABLE `person_investments` ADD CONSTRAINT `person_investments_fk0` FOREIGN KEY (`person_id`) REFERENCES `person`(`id`);

ALTER TABLE `person_investments` ADD CONSTRAINT `person_investments_fk1` FOREIGN KEY (`company_id`) REFERENCES `company`(`id`);

ALTER TABLE `university` ADD CONSTRAINT `university_fk0` FOREIGN KEY (`city`) REFERENCES `city`(`id`);


-- Generation time: Mon, 18 Nov 2019 16:47:57 +0000
-- Host: mysql.hostinger.ro
-- DB name: u574849695_25
/*!40030 SET NAMES UTF8 */;
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP TABLE IF EXISTS `city`;
CREATE TABLE `city` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `country_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `city_fk0` (`country_id`),
  CONSTRAINT `city_fk0` FOREIGN KEY (`country_id`) REFERENCES `country` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `city` VALUES ('1','South Emeliebury','1'),
('2','Tannerfort','2'),
('3','Port Emerybury','3'),
('4','Norafort','4'),
('5','Lake Walker','5'),
('6','Lake Bennettmouth','6'),
('7','South Maxwellport','7'),
('8','Lake Maxinehaven','8'),
('9','Dejuanland','9'),
('10','West Jerrold','10'),
('11','Valliebury','1'),
('12','South Natview','2'),
('13','West Marianna','3'),
('14','Gayfort','4'),
('15','East Elistad','5'),
('16','East Garnettberg','6'),
('17','Melissaview','7'),
('18','West Samantha','8'),
('19','Yostmouth','9'),
('20','Mosciskifort','10'),
('21','Lexieburgh','1'),
('22','Kiannaland','2'),
('23','New Mercedesstad','3'),
('24','Littelfort','4'),
('25','North Donnamouth','5'),
('26','Tomasbury','6'),
('27','Conroychester','7'),
('28','South Cristal','8'),
('29','Port Travisbury','9'),
('30','Karleybury','10');


DROP TABLE IF EXISTS `company`;
CREATE TABLE `company` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `about` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_size` int(11) DEFAULT NULL,
  `raised` int(11) DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `twitter` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `facebook` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city_id` int(11) NOT NULL,
  `isfund` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `company_fk0` (`city_id`),
  CONSTRAINT `company_fk0` FOREIGN KEY (`city_id`) REFERENCES `city` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `company` VALUES ('1','explicabo','Ipsam nemo quasi et et hic minima et. Aut commodi eos est nobis doloribus ut tempore.','1','5','http://www.corkeryswaniawski.com/','http://www.denesik.info/','http://www.hyatt.com/','6','0'),
('2','doloremque','Exercitationem ad quibusdam quas voluptatem consequuntur aut. Et repellendus tenetur aspernatur qui est id voluptatibus. Amet quis ut unde sint consequuntur tempore.','5','57540308','http://www.mclaughlin.com/','http://crist.com/','http://mcclureokuneva.com/','7','1'),
('3','est','Suscipit ut placeat et praesentium. Corporis maiores ullam et. Quaerat expedita repellendus ea ipsum vel reiciendis. In non quos non minima expedita sequi fuga.','3','0','http://www.hermanfarrell.net/','http://www.hodkiewiczzieme.org/','http://www.sauer.com/','13','0'),
('4','eaque','Cupiditate animi placeat dolores est. Dolores quo amet doloremque veritatis impedit ullam. Enim dicta quis totam provident nesciunt id non. Nostrum voluptas qui dignissimos vel.','9','782892','http://kling.com/','http://monahanlittel.info/','http://fadel.com/','20','1'),
('5','nam','Ut necessitatibus saepe veritatis ut harum commodi. Nostrum incidunt nisi cumque in est quos. Recusandae eum ipsa fugiat magnam. Voluptas qui hic quasi sed.','6','32','http://www.cassinsenger.com/','http://hermistonhoppe.biz/','http://www.wolf.net/','17','0'),
('6','magnam','Sint dolorem debitis eos illum dignissimos exercitationem. Iusto alias exercitationem minus. Sed distinctio doloribus sed quia odio in consequatur corrupti. Numquam sed sequi consectetur commodi.','7','907','http://dickens.net/','http://www.runolfsdottirerdman.com/','http://jenkins.info/','19','1'),
('7','et','Doloribus quia sed reiciendis ut culpa. Repellendus unde est quo placeat. At sit quia quis rerum natus qui natus. Cupiditate ut consequuntur odit error.','6','8','http://www.hane.com/','http://www.lang.biz/','http://bernier.com/','20','1'),
('8','ullam','Vel quia blanditiis laborum beatae rem omnis doloribus. Consectetur ex qui fugiat ducimus. Laudantium ex recusandae consequuntur et ducimus et atque.','6','517','http://www.andersonsauer.com/','http://www.wisoky.org/','http://watsica.info/','15','1'),
('9','praesentium','Laudantium ut adipisci et aut occaecati omnis. Architecto qui aut quo provident recusandae quae. Necessitatibus ducimus inventore quia. Nam at sit eos repellat omnis.','8','79','http://www.rohan.com/','http://www.bechtelarreilly.com/','http://www.criststamm.com/','9','1'),
('10','maiores','Accusantium ea recusandae magni velit quaerat voluptates quia. Voluptate cumque officiis eligendi aperiam et. Asperiores distinctio id laboriosam suscipit odio.','4','1126','http://fritschhudson.biz/','http://langworth.com/','http://www.damore.com/','29','1'),
('11','aut','Eum sit ut reiciendis quia. Voluptatum alias enim repudiandae earum vitae. Sit vero natus molestiae quis.','7','5833931','http://schimmel.com/','http://kreigerschaefer.com/','http://www.nitzschewisoky.com/','18','1'),
('12','excepturi','Fugit qui occaecati veritatis exercitationem aut voluptatem rerum. Est sint possimus placeat eius.','1','711','http://simonis.net/','http://www.abshirecarroll.org/','http://www.reinger.com/','7','0'),
('13','incidunt','Quo impedit nobis eum et qui omnis. Illo corrupti voluptas sit ea dolore. Ut id ut vero vitae aut. Cum a doloribus quas error.','3','8','http://www.schultz.info/','http://www.runte.com/','http://www.hackett.com/','1','1'),
('14','ea','Adipisci quaerat maiores soluta occaecati. Voluptatem rerum ipsam ratione neque atque adipisci neque. Molestiae vitae sint placeat repudiandae sit iste. Voluptatibus magnam ut nihil placeat est perferendis. Reiciendis et enim earum tempora unde earum.','6','9497497','http://fisher.com/','http://www.pfeffer.com/','http://pagac.info/','24','0'),
('15','et','Praesentium velit sit quis culpa repellendus enim tempora. Soluta exercitationem vitae perspiciatis suscipit. Aliquam blanditiis eos qui excepturi culpa voluptas mollitia molestias.','2','70434914','http://www.champlin.biz/','http://www.lang.net/','http://rennerstehr.com/','27','1'),
('16','maiores','Provident explicabo molestiae autem facere doloremque voluptas aut. Et officia temporibus facere et earum. Doloribus labore necessitatibus officia velit non officia.','2','539227184','http://www.klocko.com/','http://www.kulas.net/','http://wittingstokes.com/','6','0'),
('17','tenetur','Eaque totam animi non dolores minus sit libero. Fugiat ut dolores esse soluta in ipsum nihil. Eaque amet fuga quia corrupti sunt error voluptas. Et sapiente non nam et.','9','219658','http://fadel.com/','http://www.hermiston.com/','http://www.mante.com/','3','0'),
('18','quisquam','Sit quo aut est asperiores qui. Quo veritatis expedita repellendus minus distinctio ratione repudiandae. Sit soluta beatae nam accusamus.','9','44','http://hayes.com/','http://www.emard.com/','http://www.halvorson.com/','6','0'),
('19','et','Voluptatem nulla illum ea. Explicabo ea reiciendis porro molestias quo vitae repellendus et. Voluptatem voluptates quis magnam placeat tenetur labore.','1','410976','http://turner.com/','http://www.whitegaylord.com/','http://www.dibbert.com/','28','1'),
('20','facere','Non esse occaecati rerum accusamus laudantium. Voluptatem ut pariatur cupiditate voluptates eveniet nihil occaecati. Accusantium aliquam culpa occaecati deserunt qui molestiae.','2','9729497','http://www.spinkabarrows.net/','http://jacobi.biz/','http://weber.com/','12','0'),
('21','et','Illum laboriosam qui nam quia aut. Reiciendis quis ab debitis inventore.','7','51245','http://townemcglynn.org/','http://simonis.biz/','http://www.bechtelar.com/','27','0'),
('22','minus','Vel repellendus porro id et ad et expedita. Non non dolores libero eum. Dolore ab nulla voluptatibus beatae ipsum incidunt.','4','74392205','http://hermann.net/','http://purdy.com/','http://torphy.com/','14','0'),
('23','voluptas','Nostrum architecto dignissimos beatae nobis. Est suscipit eius nesciunt. A itaque a in natus et.','6','86587','http://www.torphywisoky.biz/','http://www.roberts.com/','http://morarchristiansen.org/','28','0'),
('24','ea','Maxime blanditiis molestias architecto voluptatibus suscipit earum veritatis. Culpa est qui quam. Ratione quia ea nam facilis voluptate dolor enim voluptatem. Consequatur aut sint sed est sit.','8','32','http://www.aufderharmaggio.com/','http://bins.com/','http://www.mckenzie.com/','15','1'),
('25','voluptatibus','Delectus voluptates laudantium rerum eum minima molestiae ea. Modi laborum et ad voluptatem aperiam fugit. Officiis possimus et necessitatibus minima voluptas ex a soluta. Minima delectus quae eligendi recusandae adipisci ea omnis sequi.','2','0','http://www.walkergerlach.net/','http://www.rutherfordabbott.com/','http://www.wardgreenholt.net/','19','0'),
('26','eum','Ratione placeat architecto iure soluta et sunt sed porro. Ut occaecati voluptatibus nihil non. Dolores dolorem dolorem repellat ab inventore dolores. Provident ducimus molestiae illo sed. Hic quia consequatur culpa dolorem iste animi ullam vero.','1','8','http://www.corwinwilderman.info/','http://www.welchkuhn.biz/','http://cormier.com/','8','1'),
('27','vitae','Esse voluptas et qui possimus voluptatem praesentium. Dolores nobis sunt repudiandae officia. Non debitis facere tenetur iure et.','2','7630085','http://www.hegmann.com/','http://www.monahan.net/','http://www.bartoletti.com/','21','1'),
('28','voluptatum','Sequi vel natus est possimus qui ut. Et et laudantium delectus necessitatibus.','4','8495','http://rice.com/','http://smith.org/','http://williamson.com/','8','1'),
('29','dolorem','Repellat maxime vero nam aut maxime eum dolorum. Repellat nam quia est enim delectus est nulla fugit.','5','87688','http://www.hellerdurgan.com/','http://www.baumbachstamm.info/','http://kemmer.com/','25','1'),
('30','optio','Eius consequuntur esse aut odio. Autem temporibus et voluptas dolore laudantium cumque voluptates. Deserunt est fuga velit corporis velit sunt. Corrupti est libero illum animi assumenda accusamus et.','2','92','http://www.sauerkuvalis.biz/','http://ziemann.com/','http://oharabotsford.com/','13','1'),
('31','perferendis','Labore consequatur et est. In quo unde labore recusandae rerum repellat. Sed quasi ut aut quia.','6','3165','http://www.danielcarroll.net/','http://www.labadie.com/','http://stanton.biz/','18','1'),
('32','itaque','Soluta enim autem accusamus. Ea et sed sunt sunt tempore fuga quas molestiae. Quo ducimus voluptas maiores at. Animi in voluptatem eius quia.','2','22','http://bernhard.biz/','http://framiklocko.org/','http://schmidt.com/','1','1'),
('33','adipisci','Quibusdam consectetur voluptatem id unde cupiditate. Voluptas repellat laudantium voluptas aperiam rerum at inventore. Rerum unde non rerum dolores nam esse. Quos dolores aut delectus maiores iusto.','3','6039466','http://www.mante.com/','http://larson.com/','http://hintzwalsh.com/','19','1'),
('34','nesciunt','Aut iusto reiciendis accusantium ipsam voluptatem illum sunt. Nesciunt aperiam ut et dolores in explicabo. Nam rerum iusto unde ex.','7','50746','http://www.marvinbahringer.org/','http://yundtwill.org/','http://bartonkoss.net/','1','1'),
('35','non','Ut velit voluptas sapiente cumque quisquam. Voluptatibus deleniti est est aut pariatur a. Totam mollitia omnis ab quas et. Sint vel cupiditate tempora sunt.','8','16','http://www.mckenzie.org/','http://www.green.net/','http://www.fritsch.org/','21','1'),
('36','omnis','Dolorum quaerat nihil unde nisi dolores nobis. Consequatur ipsum repellat et enim. Quia earum ut error ut voluptas et doloribus.','7','9','http://russel.com/','http://www.okunevajacobs.com/','http://schuster.info/','5','1'),
('37','sed','Quod perspiciatis nihil enim inventore quis maiores nihil. Ipsam possimus incidunt consequatur amet placeat quisquam dolorem. Soluta ut voluptas voluptatibus voluptate asperiores. Fuga laborum aut voluptatem.','2','9116413','http://tromp.com/','http://goyette.com/','http://leuschke.org/','20','0'),
('38','quod','Aut illum quia dolorum molestias nisi. Ab minima qui quia omnis.','7','1','http://weimann.info/','http://www.strosin.com/','http://www.steuber.com/','10','1'),
('39','voluptas','Quis non nobis perferendis quam dolore nobis recusandae. Similique eius veritatis incidunt ab. Illo ut aut nam voluptatem qui reiciendis placeat. Voluptate magni iste ipsam sed dolores iure.','7','762172595','http://www.parisianspinka.com/','http://bernhard.com/','http://goyette.com/','20','1'),
('40','autem','Ipsa est dolorem ea dolor est voluptatibus voluptas. Facere dolorem omnis amet animi aut ex provident. Sed culpa ut fugit voluptatem quia sunt. Est ea enim quo maxime quo eum.','4','212','http://www.emardabbott.com/','http://www.pricemckenzie.biz/','http://vonrueden.com/','28','1'),
('41','ipsum','Officiis enim nam a voluptatum dolorum ut. Quia ut esse minus aspernatur sed velit. Corrupti pariatur velit occaecati harum ad.','4','3813251','http://kihn.com/','http://www.cruickshank.net/','http://www.krajcik.com/','9','1'),
('42','voluptatem','Laudantium labore beatae quibusdam quae et nostrum laudantium. Vitae dignissimos velit neque non ut non voluptas et. Est porro voluptatem nihil atque ut exercitationem repellat.','8','0','http://mosciski.com/','http://www.larsonmante.com/','http://www.schneider.com/','8','0'),
('43','officia','Voluptatem ut omnis placeat dolorem. Consequatur autem fugit rerum sit et architecto excepturi numquam. Maxime et itaque quia quis et quo.','3','7030277','http://volkman.org/','http://www.buckridge.com/','http://www.yost.org/','5','0'),
('44','voluptatibus','Atque omnis ut est deserunt id qui rerum. Voluptatem et molestiae aliquid perferendis. Totam et repellendus necessitatibus unde laborum. Et consequuntur alias consectetur doloremque nihil qui cupiditate id.','4','3930582','http://osinski.com/','http://www.kassulke.info/','http://www.collierparker.org/','10','0'),
('45','enim','Laudantium et neque et et sed. Nihil laudantium dolorum magni eligendi unde. Quia omnis qui deleniti aliquid non. Aut velit sunt vel consectetur aut reiciendis.','6','63','http://pourosabernathy.com/','http://mcclure.info/','http://www.rice.com/','1','1'),
('46','ut','Sapiente dolor autem et ea esse velit autem. Repudiandae asperiores sint impedit non vel. Eos velit aliquid laboriosam quia.','8','3515','http://dickens.com/','http://rippin.biz/','http://bahringer.com/','2','1'),
('47','magni','Ex sint a consequatur voluptas eligendi impedit inventore. Quidem eligendi hic dolorem voluptatem. Voluptas reiciendis sit perspiciatis unde animi est.','1','7','http://www.altenwerth.com/','http://olson.com/','http://stantonschuster.com/','15','0'),
('48','veritatis','Nihil id rerum ratione molestiae adipisci rem aliquid. Sequi culpa fugit et ipsum sit. Et qui velit dolorum. Et sit ut laborum temporibus consequatur fuga et iure.','9','8726398','http://gerlach.info/','http://www.gibson.com/','http://www.fay.net/','3','1'),
('49','quis','Officiis et minus nihil nesciunt aut repellendus ut. Repellat corporis delectus quibusdam dolorem odit. Corporis in illo minus libero quae maiores ut. Ipsam quis repellendus repudiandae sint repudiandae et ad.','5','6','http://murray.com/','http://beer.biz/','http://runolfsdottir.com/','7','1'),
('50','cumque','Esse aut voluptatum saepe qui accusantium cum. Et fugiat porro eum dicta error. Eligendi tempore vel dolor officiis laboriosam assumenda.','6','6717','http://www.abernathy.net/','http://www.frami.com/','http://www.dach.com/','13','1'),
('51','nihil','Perferendis molestias quos officiis quia culpa ut. Sed ratione debitis facere cumque vitae rem. Corporis sapiente in debitis aperiam omnis a. Qui quae sed quia ratione distinctio ducimus.','9','79170290','http://www.bednar.com/','http://koelpin.com/','http://www.daniel.com/','15','1'),
('52','alias','Praesentium veniam aliquid eum illo natus inventore rerum. Nihil quasi consectetur quia itaque commodi. Est sunt maiores rerum velit. Doloribus quisquam odit aspernatur molestiae.','9','0','http://www.wintheiser.com/','http://connelly.com/','http://www.johnson.net/','4','0'),
('53','perspiciatis','Qui sit qui iure rerum et rerum quia eos. Aspernatur omnis qui soluta consequatur. Laudantium pariatur exercitationem molestias pariatur repudiandae quis. Voluptatem voluptatem debitis ut ut magnam aut quo.','5','626258','http://lueilwitz.com/','http://www.windler.com/','http://dachwilderman.com/','27','1'),
('54','accusamus','Nihil iure molestias provident amet minus similique. Atque incidunt quia ipsa fugiat esse similique. Ex dolor et velit voluptatem. Ratione error qui dolore et.','5','5500','http://www.kris.info/','http://www.dickinson.com/','http://jonesluettgen.com/','13','0'),
('55','et','Eligendi fugiat ut maiores consequatur vel fuga eligendi. Amet provident exercitationem et aspernatur reiciendis.','8','163','http://www.kohler.com/','http://www.abshire.biz/','http://willlarson.com/','19','1'),
('56','consequuntur','Vel sequi ut vel commodi recusandae. Et nesciunt eos id vel aperiam perferendis. Et sunt sequi impedit.','2','6782','http://yundt.com/','http://brakus.com/','http://keeling.info/','15','1'),
('57','dolore','Dignissimos alias aperiam quidem ut quis dolore. Magni soluta aut eveniet eum.','2','754958','http://orn.com/','http://www.koelpinbednar.com/','http://kihn.com/','20','0'),
('58','qui','Amet non quia voluptate cum. Assumenda magni quis ut. Cupiditate esse consequatur voluptatum qui a eligendi.','9','214564491','http://www.haleyschiller.com/','http://www.eichmanndickinson.com/','http://blickleuschke.com/','9','0'),
('59','a','Sequi consequuntur magnam qui ut eum vero. Qui sed tempore delectus incidunt asperiores. Adipisci id voluptas et voluptates.','7','77771','http://www.reichertspinka.info/','http://www.leannon.org/','http://www.ornleuschke.com/','22','1'),
('60','quo','Enim autem eos dicta vero. Odio voluptatem et enim atque alias repellat. Debitis doloribus provident recusandae fugiat esse unde totam ab. Enim quos perferendis quas quod delectus delectus ea. Velit iusto quia amet consequatur quia optio.','2','9281516','http://powlowski.com/','http://borer.com/','http://www.kerlukemccullough.com/','15','1'),
('61','id','Molestiae eaque non ut non doloribus suscipit voluptatem. Id cumque autem molestiae eius. Qui ab voluptatem ratione velit. Tempore vitae quia totam impedit fugit occaecati voluptas voluptas. Numquam voluptatibus alias impedit eos laborum id est.','9','579177665','http://www.luettgenlebsack.com/','http://zboncak.com/','http://bauch.net/','22','1'),
('62','eligendi','Deleniti non accusamus enim fugit nam. Excepturi perferendis quia aut nobis in sed. Harum animi minima quae facere aut eum vero.','4','123','http://leschstark.info/','http://sanfordernser.biz/','http://considine.org/','10','0'),
('63','ut','Sint dolores est sit quis distinctio corrupti. Saepe voluptate nisi maxime enim quia. Vero inventore consequatur doloribus necessitatibus cumque aut quos. At et culpa explicabo quibusdam ipsum. Ab quo id quam vel.','5','64876238','http://www.schroeder.com/','http://murray.biz/','http://www.strosintromp.com/','16','1'),
('64','consectetur','Numquam similique quam vitae harum quam explicabo dolores. Fugit voluptatum qui architecto. Fuga rem quia harum excepturi reiciendis consectetur error reiciendis. Ipsum molestias quisquam ab earum fuga.','2','4','http://www.effertzcronin.net/','http://www.green.com/','http://lowepredovic.com/','10','0'),
('65','autem','Impedit esse laudantium dolore. Rerum aperiam sequi perferendis repellendus iste. Voluptas officia voluptates iste distinctio. Nobis iure ab non qui non.','6','8','http://harber.net/','http://www.daughertyhettinger.com/','http://lubowitzmurphy.com/','10','1'),
('66','dolorem','Architecto odit eaque eos et nam quod ipsam. Eaque consectetur tenetur reprehenderit. Vel eum a voluptate non dolores fugiat rerum excepturi. Dolor ad natus corrupti distinctio porro veritatis aut.','9','0','http://www.kiehnmuller.com/','http://torp.com/','http://www.jones.com/','6','1'),
('67','blanditiis','Enim maxime voluptatibus culpa laudantium quidem sint a. Non temporibus vitae quas alias facilis aut consequatur. Tempore recusandae enim laudantium ipsa aut explicabo aperiam. Alias velit voluptas adipisci numquam enim alias.','7','115914','http://littlemorar.net/','http://hyatt.com/','http://jast.biz/','15','1'),
('68','ipsum','Eum unde sapiente odio rerum in fugiat omnis. Necessitatibus laborum aut tempore consequatur earum non nam.','1','584665','http://strackeschulist.org/','http://www.nikolaus.com/','http://www.mosciskilangworth.com/','29','0'),
('69','earum','Dignissimos est nostrum ad quia perferendis. Consectetur qui et consequatur. Odio accusantium vel fugit.','3','51425915','http://kuphaljast.com/','http://www.bode.com/','http://adams.com/','16','0'),
('70','libero','Sed soluta adipisci blanditiis eligendi ipsum temporibus necessitatibus. Error est quasi sunt qui.','4','2','http://www.trompkuvalis.com/','http://www.hellergusikowski.com/','http://www.rice.org/','5','0'),
('71','a','Commodi tempora a itaque sunt sit aut ratione. Hic harum praesentium aut reiciendis. Nihil officia eligendi et consequuntur hic quod blanditiis.','5','589','http://www.raynor.com/','http://www.bogisich.biz/','http://waelchijakubowski.info/','26','1'),
('72','asperiores','Omnis deleniti odit sint neque quo eius laudantium. Earum qui aut autem quia aspernatur. Qui odit quam temporibus consequatur voluptates. Velit eos laudantium et qui ipsa vero.','9','590','http://www.hodkiewicz.net/','http://lynch.com/','http://dubuquewillms.net/','24','1'),
('73','libero','Aut non beatae quisquam qui. Est est veniam hic voluptates voluptatum. Ea quisquam nesciunt temporibus qui placeat dolores quis.','4','62106','http://www.watsica.com/','http://spencer.com/','http://oreillybergstrom.com/','12','1'),
('74','officiis','Distinctio sit dolore soluta repudiandae aliquam laborum ut. Eos cum ut est repellat. Vitae ut dolores iste earum voluptatum occaecati iste rerum. Sit iste veniam assumenda error dolorum sit saepe.','7','1','http://www.feest.net/','http://kassulke.com/','http://www.turcotte.org/','1','1'),
('75','eligendi','Et qui animi praesentium aliquid. Similique quibusdam dolores qui perspiciatis. Quisquam minus facere placeat quis repellendus ut. Dolores id qui voluptas non aspernatur ut.','8','0','http://www.weissnat.com/','http://mertz.com/','http://www.mayermaggio.org/','3','1'),
('76','veritatis','Aut qui dolore nisi exercitationem et et illo. Ea officiis alias cum ea. Autem esse ut dignissimos molestiae eum omnis. Non blanditiis beatae libero est labore praesentium.','8','5481','http://waelchi.com/','http://effertz.com/','http://donnellythiel.com/','13','0'),
('77','delectus','Quia quasi eum placeat exercitationem eum. Maiores eum ut doloribus ut id. Sunt molestiae et excepturi dolores deserunt omnis ad.','9','74920349','http://www.haleycremin.com/','http://bauch.com/','http://tremblay.com/','2','0'),
('78','assumenda','Minus cupiditate est nihil at est dolores. Sed odio cupiditate veniam non ratione. Autem aliquid sint quidem ipsam neque dignissimos ut ad. Doloribus sit eligendi iure excepturi minima.','1','16504720','http://www.mckenzie.net/','http://www.herzog.com/','http://schmittkonopelski.com/','18','0'),
('79','magnam','Assumenda magni cupiditate debitis eaque dolore aut. Ut eaque commodi necessitatibus. Velit dolores ut nostrum omnis in a.','5','21','http://www.hegmannhagenes.com/','http://johnston.biz/','http://www.schmitt.info/','15','0'),
('80','vel','In exercitationem esse ab maiores omnis modi. Et aut iste exercitationem occaecati iure natus. Suscipit architecto ut dolores pariatur fugit qui. Aspernatur id nulla voluptas natus maiores sint a.','9','929','http://www.oconnell.com/','http://www.heidenreichbarrows.net/','http://www.bahringer.com/','9','1'),
('81','reprehenderit','Qui eum qui molestiae et. Necessitatibus porro animi possimus neque natus inventore praesentium. Aliquid dolorem numquam et et. Voluptatem et omnis iusto nam delectus consequatur.','4','58093','http://townecasper.com/','http://www.oconnerwehner.info/','http://www.runolfssonhowell.com/','30','0'),
('82','qui','Aut qui fuga itaque aut temporibus. Illum dolorum ipsum consequatur quia. In neque perspiciatis aut enim omnis. Aut debitis ipsam quibusdam et quaerat quibusdam iusto.','1','6','http://king.biz/','http://block.com/','http://bednar.com/','29','0'),
('83','dignissimos','Adipisci reiciendis aut odit pariatur facilis. Autem magnam rerum asperiores in cupiditate molestias. Voluptates rem quam id sunt recusandae maxime fugiat. Qui saepe neque quibusdam corrupti illum est doloremque.','1','3602','http://www.harvey.com/','http://schulist.info/','http://www.hermann.com/','12','0'),
('84','voluptates','Eum soluta nobis vitae modi magnam cupiditate. Corrupti quia repellendus omnis aut unde distinctio. Culpa est ab iusto. Non ad nesciunt nostrum commodi voluptatem odio et.','7','16845','http://dibbertdibbert.net/','http://vandervort.com/','http://www.blickwisozk.com/','27','1'),
('85','aut','Quis et sit et qui. Debitis deserunt nihil corporis quibusdam eos nesciunt ut. Quidem maxime neque qui tempora neque maiores quaerat.','3','195319898','http://sauer.net/','http://www.mraz.com/','http://www.rutherford.org/','12','1'),
('86','accusantium','Accusamus quas enim autem ut. Inventore qui impedit tempore ipsa possimus. Sit molestias eum sit pariatur aut architecto doloremque. Rem ipsum ut voluptatem libero.','3','66171117','http://kub.org/','http://rogahn.com/','http://www.altenwerthpadberg.com/','1','1'),
('87','id','Recusandae est et in. Sunt dolores et aperiam doloribus beatae mollitia asperiores est. Labore cumque pariatur quo. Sint facilis aliquid laudantium.','3','3','http://rohanjohns.com/','http://parisian.net/','http://www.morar.com/','11','0'),
('88','aut','Officiis odio maxime id et ad. Expedita corrupti rem labore perferendis vitae ut adipisci officiis. Voluptas cupiditate in itaque voluptatem qui fuga similique. Perspiciatis ad at et.','4','34145','http://waters.com/','http://www.wintheiser.com/','http://www.hartmann.com/','1','0'),
('89','autem','Reiciendis blanditiis unde non perferendis modi dolore reiciendis. Consequatur mollitia fugit minima et totam officia similique. Sunt earum ut perferendis. Et optio voluptatem dolorem voluptatem.','5','344311','http://www.bahringer.com/','http://lebsackmccullough.biz/','http://www.harris.com/','10','0'),
('90','quam','Sequi sit quis voluptates quibusdam quod recusandae voluptatibus. Eaque sequi sequi ut nostrum hic. Maxime quaerat et nemo deserunt reprehenderit quia eos. Voluptas adipisci odio in nulla.','6','8534','http://rutherford.info/','http://sawaynhammes.com/','http://sawayn.com/','3','1'),
('91','expedita','Dignissimos beatae dolor consequatur. Et similique mollitia quas enim quisquam est. Non vel odit voluptas reiciendis aspernatur reprehenderit.','4','10','http://mertz.com/','http://www.schultz.com/','http://www.mante.biz/','16','0'),
('92','velit','Eius molestias accusantium iusto. Ducimus et est laboriosam sit architecto. Impedit magnam quasi ad vero. Debitis ducimus sed ipsam possimus tempore minima. Et dolorem neque maxime adipisci quis veniam.','2','7','http://klocko.biz/','http://pacocha.biz/','http://www.boderomaguera.org/','1','1'),
('93','tempore','Similique molestiae fugit soluta hic et. Animi dolores et eos error nostrum ut quos. Cupiditate officia et asperiores praesentium omnis. Quidem sed voluptatem minus corporis eveniet reprehenderit et.','1','802970703','http://www.treutel.com/','http://www.wehner.com/','http://ward.biz/','13','0'),
('94','voluptatibus','Ea maiores ut magnam. Quas aut et non ducimus quaerat sed. Est quibusdam ad amet aut impedit.','2','675350221','http://hackett.info/','http://www.ondricka.info/','http://www.balistrerifarrell.org/','1','1'),
('95','illo','Ut at quia id nemo exercitationem qui. Corrupti aut non architecto consequatur ullam maxime facere. Non perferendis architecto doloribus cupiditate officiis et qui ut.','4','0','http://paucek.com/','http://www.bartell.com/','http://www.wolffkertzmann.biz/','11','1'),
('96','deserunt','Soluta iure ut modi deleniti aut voluptates laudantium distinctio. Incidunt ut ea commodi vel dicta.','9','1','http://trantowzulauf.com/','http://raynorjacobi.com/','http://www.paucek.com/','22','1'),
('97','dolor','Accusantium saepe nemo earum voluptatem debitis est. Sit dolorem accusantium alias ut. Dolor id ea blanditiis eligendi error adipisci. Animi et velit inventore totam in voluptas.','5','12222','http://www.mcglynn.com/','http://www.feil.biz/','http://morissette.biz/','6','0'),
('98','ad','Inventore est iure sint nihil illo omnis exercitationem. Voluptatem iusto fugit laudantium non provident. Qui blanditiis iure possimus molestiae deleniti dolor. Officiis id atque ipsam eius velit ut.','6','687','http://davislesch.org/','http://nitzsche.com/','http://www.brekke.com/','26','0'),
('99','optio','Ex suscipit in ea. Cumque quasi sed dolores molestias dolores sit non. Animi nemo nihil quibusdam mollitia. Molestiae accusamus qui eveniet maxime et.','2','98867','http://www.schultz.com/','http://rogahn.com/','http://www.bechtelarritchie.com/','20','1'),
('100','vel','Aut hic quas impedit nisi distinctio similique. Aliquid aliquam rerum architecto perferendis. Ab quas est consequuntur ullam recusandae quia. Reprehenderit autem ducimus voluptas minus est.','2','8665480','http://yundt.com/','http://www.vonrueden.com/','http://www.oconner.com/','21','0');


DROP TABLE IF EXISTS `company_investment`;
CREATE TABLE `company_investment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `investor_id` int(11) NOT NULL,
  `investment_id` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `date_invested` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `company_investment_fk0` (`investor_id`),
  KEY `company_investment_fk1` (`investment_id`),
  CONSTRAINT `company_investment_fk0` FOREIGN KEY (`investor_id`) REFERENCES `company` (`id`),
  CONSTRAINT `company_investment_fk1` FOREIGN KEY (`investment_id`) REFERENCES `company` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `company_investment` VALUES ('1','83','35','1990025','1996-07-24'),
('2','72','80','1091732','1975-01-23'),
('3','63','6','1183688','1979-06-29'),
('4','20','42','333265','1979-07-31'),
('5','88','89','1001673','2003-03-19'),
('6','91','49','45745','1980-02-06'),
('7','93','92','1153697','2017-04-09'),
('8','53','45','867441','2019-11-11'),
('9','56','76','939502','2004-11-03'),
('10','98','23','861390','1989-01-19'),
('11','83','8','1826149','2009-01-04'),
('12','65','7','1686270','2007-05-20'),
('13','93','15','755287','2018-01-19'),
('14','39','52','694509','1976-04-05'),
('15','51','50','892349','2011-03-11'),
('16','32','33','1623851','2009-05-03'),
('17','84','3','969835','1992-06-30'),
('18','13','47','214319','2015-10-11'),
('19','9','32','529','1973-12-07'),
('20','88','96','1755621','1986-03-14'),
('21','21','79','1953575','2005-10-31'),
('22','45','13','1630522','2014-12-01'),
('23','70','97','725846','1995-11-20'),
('24','58','26','1726009','1982-04-17'),
('25','73','55','1398365','2011-11-15'),
('26','48','55','1611263','1978-11-16'),
('27','62','13','684449','2014-01-13'),
('28','61','54','1212723','2004-10-30'),
('29','27','100','1782060','1987-05-18'),
('30','6','77','1574968','1975-03-23'),
('31','14','32','174968','1975-01-23'),
('32','21','32','674968','1985-11-14');


DROP TABLE IF EXISTS `company_market`;
CREATE TABLE `company_market` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `market_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `company_market_fk0` (`company_id`),
  KEY `company_market_fk1` (`market_id`),
  CONSTRAINT `company_market_fk0` FOREIGN KEY (`company_id`) REFERENCES `company` (`id`),
  CONSTRAINT `company_market_fk1` FOREIGN KEY (`market_id`) REFERENCES `market` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `company_market` VALUES ('1','1','1'),
('2','2','2'),
('3','3','3'),
('4','4','4'),
('5','5','5'),
('6','6','6'),
('7','7','7'),
('8','8','8'),
('9','9','9'),
('10','10','10'),
('11','11','11'),
('12','12','12'),
('13','13','13'),
('14','14','14'),
('15','15','15'),
('16','16','16'),
('17','17','17'),
('18','18','18'),
('19','19','19'),
('20','20','20'),
('21','21','21'),
('22','22','22'),
('23','23','23'),
('24','24','24'),
('25','25','25'),
('26','26','26'),
('27','27','27'),
('28','28','28'),
('29','29','29'),
('30','30','30'),
('31','31','31'),
('32','32','32'),
('33','33','33'),
('34','34','34'),
('35','35','35'),
('36','36','36'),
('37','37','37'),
('38','38','38'),
('39','39','39'),
('40','40','40'),
('41','41','41'),
('42','42','42'),
('43','43','43'),
('44','44','44'),
('45','45','45'),
('46','46','46'),
('47','47','47'),
('48','48','48'),
('49','49','49'),
('50','50','50'),
('51','51','51'),
('52','52','52'),
('53','53','53'),
('54','54','54'),
('55','55','55'),
('56','56','56'),
('57','57','57'),
('58','58','58'),
('59','59','59'),
('60','60','60'),
('61','61','61'),
('62','62','62'),
('63','63','63'),
('64','64','64'),
('65','65','65'),
('66','66','66'),
('67','67','67'),
('68','68','68'),
('69','69','69'),
('70','70','70'),
('71','71','71'),
('72','72','72'),
('73','73','73'),
('74','74','74'),
('75','75','75'),
('76','76','76'),
('77','77','77'),
('78','78','78'),
('79','79','79'),
('80','80','80'),
('81','81','81'),
('82','82','82'),
('83','83','83'),
('84','84','84'),
('85','85','85'),
('86','86','86'),
('87','87','87'),
('88','88','88'),
('89','89','89'),
('90','90','90'),
('91','91','91'),
('92','92','92'),
('93','93','93'),
('94','94','94'),
('95','95','95'),
('96','96','96'),
('97','97','97'),
('98','98','98'),
('99','99','99'),
('100','100','100');


DROP TABLE IF EXISTS `country`;
CREATE TABLE `country` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `country` VALUES ('1','Algeria'),
('9','Belgium'),
('2','Bermuda'),
('8','Georgia'),
('7','Ghana'),
('4','Jordan'),
('3','Mexico'),
('10','Saint Kitts and Nevis'),
('5','Senegal'),
('6','Tuvalu');


DROP TABLE IF EXISTS `market`;
CREATE TABLE `market` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `market` VALUES ('21','ab'),
('76','accusantium'),
('28','adipisci'),
('92','aliquam'),
('98','aliquid'),
('50','amet'),
('48','animi'),
('60','aperiam'),
('87','architecto'),
('64','aspernatur'),
('75','at'),
('8','aut'),
('73','autem'),
('97','beatae'),
('33','consequatur'),
('30','consequuntur'),
('14','corrupti'),
('17','cumque'),
('88','delectus'),
('63','deleniti'),
('82','dicta'),
('91','dignissimos'),
('23','dolor'),
('42','dolorem'),
('49','dolores'),
('59','doloribus'),
('29','ea'),
('54','eaque'),
('67','earum'),
('71','eligendi'),
('41','eos'),
('37','esse'),
('34','est'),
('16','et'),
('22','eum'),
('94','ex'),
('24','expedita'),
('40','facere'),
('61','fugiat'),
('86','illo'),
('89','impedit'),
('35','inventore'),
('45','ipsam'),
('52','iste'),
('26','iure'),
('56','labore'),
('68','laudantium'),
('13','libero'),
('38','magnam'),
('3','maiores'),
('36','minima'),
('27','minus'),
('53','modi'),
('100','molestiae'),
('81','mollitia'),
('4','nam'),
('85','necessitatibus'),
('57','nemo'),
('93','nihil'),
('1','non'),
('11','nostrum'),
('80','occaecati'),
('70','odit'),
('12','officiis'),
('83','omnis'),
('9','possimus'),
('2','quasi'),
('20','qui'),
('79','quia'),
('74','quibusdam'),
('31','quisquam'),
('77','quo'),
('19','quod'),
('58','ratione'),
('96','recusandae'),
('44','reiciendis'),
('95','rem'),
('62','repellat'),
('69','repellendus'),
('25','reprehenderit'),
('43','repudiandae'),
('6','rerum'),
('65','sapiente'),
('18','sed'),
('39','similique'),
('46','sint'),
('7','sit'),
('32','sunt'),
('84','tempora'),
('90','tempore'),
('55','temporibus'),
('99','ullam'),
('47','unde'),
('10','ut'),
('51','vel'),
('15','velit'),
('78','veniam'),
('72','veritatis'),
('66','voluptatem'),
('5','voluptates');


DROP TABLE IF EXISTS `person`;
CREATE TABLE `person` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `lastname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `city_id` int(11) NOT NULL,
  `isinvestor` tinyint(1) NOT NULL DEFAULT 0,
  `facebook` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `about` text COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `person_fk0` (`city_id`),
  CONSTRAINT `person_fk0` FOREIGN KEY (`city_id`) REFERENCES `city` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `person` VALUES ('1','Leo','Durgan','1','0','http://crooks.com/','Ab modi consequatur nobis maiores reprehenderit. Commodi qui totam sint necessitatibus ipsum. Qui fugiat ut officiis ipsa. Ut quidem ab dolor adipisci cumque sint eveniet. Exercitationem nihil enim nihil consequatur maxime itaque ratione eos.'),
('2','Cordelia','Bartoletti','2','1','http://www.aufderharmonahan.com/','Eum et quod reiciendis a vel ratione atque. Autem officiis nisi dolorem velit unde ut. Optio sit totam velit est atque corporis similique voluptatem.'),
('3','Iliana','Hauck','3','0','http://nitzschearmstrong.com/','Atque doloremque repudiandae et at vitae repudiandae. Fugiat aut tenetur dolorem accusamus alias aut non facilis. Dolores est labore repudiandae sit qui eum quis.'),
('4','Reed','Upton','4','0','http://thompson.biz/','Et est aperiam nisi dolores eum. Nemo ut sunt optio eos quaerat molestiae. Omnis architecto tempore animi numquam ut sequi hic. Quas illum pariatur est expedita magni.'),
('5','Adrien','Mills','5','0','http://www.lakin.com/','Dolores dolorem sit vel quibusdam provident. Ducimus similique distinctio at ut temporibus sunt amet. Incidunt quia quibusdam et ea numquam assumenda. Aut nemo est autem deserunt quo.'),
('6','Gardner','Kling','6','0','http://www.volkman.info/','Dolores iste non sapiente doloremque tempora rerum quo sint. Eveniet ut aut facilis nisi. Quae iure quod fuga aspernatur nesciunt ullam et. Dolore quos maxime quia est consequatur doloribus.'),
('7','Justen','Kuhlman','7','1','http://dach.com/','Quod quia nostrum ut quis rerum dolorem. Facilis neque ipsam omnis. Vel velit dignissimos illum a. Nemo blanditiis dolorem qui quia nostrum accusamus. Illum illo animi sunt molestias.'),
('8','Lauretta','Cassin','8','0','http://kochwhite.com/','Omnis facilis veniam autem sit repellat cum odit sunt. Quas at ipsum dolore dolore quo et.'),
('9','Sincere','Runolfsson','9','0','http://kovacekwilderman.com/','Repudiandae rerum est rerum ut. Rerum et et beatae aut et et magni soluta. Quo ipsum molestias magnam veritatis beatae quod.'),
('10','Harley','Steuber','10','1','http://www.schulistthiel.info/','Dolorem dolores odit harum voluptatem quia id odit qui. Non at sed maiores ut quia eveniet. Impedit pariatur sequi eum neque consectetur. Ducimus culpa officia rem optio ducimus iusto.'),
('11','Prudence','Bartoletti','11','1','http://www.zulauf.com/','Sunt et non odio delectus vero nam. Quis minima recusandae sed ut incidunt repudiandae quos. Ut rerum officia ea rerum tempore.'),
('12','Zelda','Beier','12','1','http://hoeger.com/','Iure quia magni perspiciatis ad qui assumenda. Eum cumque fuga deserunt est.'),
('13','Anjali','Dare','13','0','http://douglas.info/','At nam doloremque repellat tempora nam. Consequuntur non quibusdam nam officiis ea ea. Aut aut temporibus fugiat accusamus.'),
('14','Bartholome','Ullrich','14','0','http://macejkovic.com/','Repudiandae debitis corrupti omnis est culpa. Aut esse accusamus ipsum consectetur sed expedita cum. Aliquam repellat aut accusantium velit. Dignissimos eos numquam enim repudiandae.'),
('15','Alexzander','Heller','15','1','http://terryglover.com/','Perferendis reiciendis et sit in iusto. Numquam sequi quam ut ut esse est quis natus. At numquam reprehenderit quas.'),
('16','Nicolas','Glover','16','1','http://www.stiedemann.com/','Alias sed consectetur iusto est. Ut dicta dolor consequuntur est. Ipsam et harum placeat deleniti quas ratione animi ut. Facilis alias corrupti corporis repellat. Qui illum rerum vel deleniti est ad.'),
('17','Priscilla','Simonis','17','1','http://bahringerdietrich.com/','Voluptatum et vel eum tenetur amet ut consequatur. Deserunt voluptatem libero veritatis sunt expedita dignissimos in. Quia voluptatibus et consequuntur similique veritatis culpa veritatis. Odit voluptas beatae ea vitae qui porro asperiores.'),
('18','Emely','Goodwin','18','0','http://www.windlerveum.com/','Aut ut eum ex at. Ipsum voluptas at enim. Quas iusto reprehenderit occaecati quis neque sed. Dolor autem hic vitae possimus facilis ad dicta.'),
('19','Earlene','Greenholt','19','1','http://www.kovacekdamore.com/','Vel distinctio cupiditate consectetur atque velit laboriosam. Enim quia occaecati nesciunt eos.'),
('20','Neva','Gottlieb','20','0','http://murazik.com/','Non deleniti earum explicabo molestiae tempora dolor. Ea quia aut libero molestiae ea occaecati beatae velit. Nobis consectetur et quam voluptatem nostrum sed possimus.'),
('21','Garnett','Huels','21','0','http://www.goodwin.com/','Officia enim laudantium ad rerum sequi saepe et. Praesentium officia et accusantium aliquid cum vel. Est ab tempora eum omnis at accusamus. Dolor nihil soluta vel. Nulla ullam aspernatur asperiores cum quisquam laborum explicabo iusto.'),
('22','Ervin','Hegmann','22','1','http://herman.org/','Neque maxime soluta a sit laudantium et. Eum repellendus est necessitatibus provident dignissimos. Vitae omnis quo fugit soluta sunt voluptatem. Libero voluptas laboriosam non qui est illum.'),
('23','Hellen','Gottlieb','23','0','http://www.koelpin.com/','Est quaerat repellendus et rerum quibusdam. Voluptas est nemo earum id enim amet magnam. Sit est est optio voluptate amet non enim. Reiciendis sapiente non deleniti deleniti est aut.'),
('24','Shanelle','Larson','24','1','http://www.dare.net/','Blanditiis vel molestiae ut quidem. Ipsa facilis perspiciatis libero vero vero recusandae sit autem. Exercitationem et laborum aut expedita explicabo quia. Inventore quisquam enim et.'),
('25','Dasia','Stark','25','1','http://www.littelschaden.net/','Et eum esse libero totam dolorem. Dolores nulla est officia. At quia hic neque ut iste at qui praesentium.'),
('26','Shea','Satterfield','26','1','http://gottliebpurdy.org/','Asperiores consequatur officia odit totam praesentium. Aut rerum dolores non quis quibusdam. Voluptas ratione nisi velit doloremque sint maiores. Molestias ea veritatis dolorem maxime autem.'),
('27','Cheyenne','Koelpin','27','1','http://funk.com/','Illum iusto molestias veritatis voluptates adipisci sed deleniti. Perspiciatis aut voluptatem quae voluptas officia doloremque. Ut itaque dolores in magnam cupiditate voluptatem.'),
('28','Camilla','Bergstrom','28','1','http://www.cummings.com/','Eveniet asperiores qui nostrum aspernatur est. Facere quis perspiciatis voluptatibus et inventore et dolorem aliquid. Non nulla neque adipisci.'),
('29','Columbus','Ritchie','29','0','http://rennerkuvalis.com/','Rerum quos aliquid molestias in. Non fugit harum et quia voluptatem.'),
('30','Name','Senger','30','0','http://www.hand.com/','Quo aut atque ut. Dicta nam quaerat sit. Voluptates debitis quae velit ut voluptatum dolore maxime adipisci. Aut officiis ullam et aut deserunt est.');


DROP TABLE IF EXISTS `person_education`;
CREATE TABLE `person_education` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `university_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `graduate` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_education_fk0` (`university_id`),
  KEY `person_education_fk1` (`person_id`),
  CONSTRAINT `person_education_fk0` FOREIGN KEY (`university_id`) REFERENCES `university` (`id`),
  CONSTRAINT `person_education_fk1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `person_education` VALUES ('1','161','1','1992-10-01'),
('2','162','2','2011-04-03'),
('3','163','3','1970-02-21'),
('4','164','4','1970-03-22'),
('5','165','5','1988-03-27'),
('6','166','6','1972-07-02'),
('7','167','7','2015-01-09'),
('8','168','8','1977-08-22'),
('9','169','9','1981-07-15'),
('10','170','10','1974-03-05'),
('11','171','11','1999-09-26'),
('12','172','12','1983-05-17'),
('13','173','13','1988-12-31'),
('14','174','14','1980-08-09'),
('15','175','15','2012-06-11'),
('16','176','16','1983-09-01'),
('17','177','17','1992-07-18'),
('18','178','18','2005-10-02'),
('19','179','19','1983-08-04'),
('20','180','20','2010-06-02'),
('21','181','21','2011-10-25'),
('22','182','22','1978-08-15'),
('23','183','23','2010-12-28'),
('24','184','24','2007-06-06'),
('25','185','25','1979-08-03'),
('26','161','26','1986-07-19'),
('27','162','27','2012-04-09'),
('28','163','28','2014-02-04'),
('29','164','29','1984-03-20'),
('30','165','30','2012-01-21');


DROP TABLE IF EXISTS `person_investments`;
CREATE TABLE `person_investments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `date_invested` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_investments_fk0` (`person_id`),
  KEY `person_investments_fk1` (`company_id`),
  CONSTRAINT `person_investments_fk0` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`),
  CONSTRAINT `person_investments_fk1` FOREIGN KEY (`company_id`) REFERENCES `company` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `person_investments` VALUES ('1','1','1','2460348','1978-10-17'),
('2','2','2','367839','1990-07-29'),
('3','3','3','571824','2017-12-02'),
('4','4','4','44380','2013-03-30'),
('5','5','5','2528242','1982-10-31'),
('6','6','6','2919696','1996-10-21'),
('7','7','7','1730239','2019-02-16'),
('8','8','8','2589580','1996-12-05'),
('9','9','9','87762','1997-09-22'),
('10','10','10','2732506','1984-05-15'),
('11','11','11','2028526','1972-05-16'),
('12','12','12','555369','2015-06-24'),
('13','13','13','558694','2015-12-23'),
('14','14','14','1999902','1970-11-25'),
('15','15','15','2500420','2002-12-26'),
('16','16','16','2090137','2009-12-07'),
('17','17','17','1300548','1985-03-25'),
('18','18','18','672117','1977-05-18'),
('19','19','19','2637911','2017-11-13'),
('20','20','20','1185989','2000-10-13'),
('21','21','21','1140410','1978-10-12'),
('22','22','22','2541009','2009-01-28'),
('23','23','23','2186623','1997-02-18'),
('24','24','24','94775','1976-04-23'),
('25','25','25','184413','2005-12-23'),
('26','26','26','2543733','2012-07-31'),
('27','27','27','1928663','1977-05-04'),
('28','28','28','2838127','1975-11-19'),
('29','29','29','2154116','1977-05-10'),
('30','30','30','564977','2000-12-25');


DROP TABLE IF EXISTS `university`;
CREATE TABLE `university` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `city` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `university_fk0` (`city`),
  CONSTRAINT `university_fk0` FOREIGN KEY (`city`) REFERENCES `city` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=186 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `university` VALUES ('161','Jimmy Inlet','1'),
('162','Duncan Mountains','2'),
('163','Ward Center','3'),
('164','Melany Isle','4'),
('165','Crooks Trail','5'),
('166','Bonita Creek','6'),
('167','Malcolm Islands','7'),
('168','Derick Ports','8'),
('169','Ella Spring','9'),
('170','Kelsi Meadows','10'),
('171','Tyree Mission','11'),
('172','Ahmad Road','12'),
('173','Johann Manors','13'),
('174','Metz Fields','14'),
('175','Jerod Spur','15'),
('176','Margret Knoll','16'),
('177','Keebler Plaza','17'),
('178','Zola Junction','18'),
('179','Christiansen Terrace','19'),
('180','Ullrich Estates','20'),
('181','Chaim Lights','21'),
('182','Kreiger Gateway','22'),
('183','Nicklaus Ville','23'),
('184','Bauch Crescent','24'),
('185','Noemie Squares','25');




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

/* sort_markets_by_popularity  */

SELECT mk.name, COUNT(*)  FROM company_market as cm JOIN market as mk on cm.market_id=mk.id GROUP BY market_id ORDER BY COUNT(*);

/* show_total_investments_of_company */
SELECT cm.name, CONCAT(SUM(ci.amount), '$') FROM company_investment as ci JOIN company as cm on ci.investment_id=cm.id GROUP BY ci.investment_id ORDER BY SUM(ci.amount);

/* show_co_investors */

SELECT company.name FROM company_investment JOIN company on company_investment.investor_id = company.id
 WHERE investment_id IN (SELECT investment_id FROM company_investment WHERE investor_id='21') AND investor_id != '21';

/* full_person_info */

CREATE OR REPLACE VIEW full_person_info AS
SELECT CONCAT(p.firstname, ' ', p.lastname) AS fullname, p.isinvestor, p.facebook, p.about, c.name as city, co.name as country FROM person as p
JOIN city as c on p.city_id = c.id
JOIN country as co on c.country_id = co.id;

SELECT * FROM full_person_info;

/*full_startup_info*/
CREATE OR REPLACE VIEW full_startup_invested_info AS
SELECT DISTINCT ci.investment_id as startup_id, co.name, co.about, co.facebook, co.twitter, co.raised,
ci1.investments_from_funds, ci3.investments_from_persons FROM company_investment as ci
JOIN company as co on ci.investment_id = co.id
JOIN (
SELECT investment_id, SUM(amount) as investments_from_funds FROM company_investment GROUP BY investment_id
) as ci1 on ci1.investment_id = ci.investment_id
JOIN (SELECT SUM(AMOUNT) as investments_from_persons, company_id FROM person_investments GROUP BY company_id)
as ci3 on ci3.company_id = ci.investment_id;

SELECT * FROM full_startup_invested_info;

DELIMITER //
DROP TRIGGER IF EXISTS on_insert_company_investments_update_raised//
CREATE TRIGGER on_insert_company_investments_update_raised BEFORE INSERT ON company_investment
FOR EACH ROW
BEGIN
	DECLARE new_amount INT;
	DECLARE previous_total INT;
	SELECT raised INTO previous_total FROM company WHERE id=new.investment_id;
	SET new_amount = previous_total + new.amount;
	UPDATE company SET raised=new_amount WHERE id = new.investment_id;
END;//

SELECT raised FROM company where id=31//
/*3165*/
INSERT INTO `company_investment` VALUES ('33','32','31','10000','1996-07-24')//
SELECT raised FROM company where id=31//
/*13165*/

DROP TRIGGER IF EXISTS on_delete_company_investments_update_raised//
CREATE TRIGGER on_delete_company_investments_update_raised AFTER DELETE ON company_investment
FOR EACH ROW
BEGIN
	DECLARE new_amount INT;
	DECLARE previous_total INT;
	SELECT raised INTO previous_total FROM company WHERE id=old.investment_id;
	SET new_amount = previous_total - old.amount;
	UPDATE company SET raised=new_amount WHERE id = old.investment_id;
END;//

SELECT raised FROM company where id=31//
/*13165*/
DELETE FROM company_investment where id=33//
SELECT raised FROM company where id=31//
/*3165*/

DROP PROCEDURE IF EXISTS repair_raised//

CREATE PROCEDURE repair_raised()
BEGIN
DECLARE id_cur INT;
DECLARE new_raised INT;
DECLARE is_end INT default 0;
DECLARE curcompany CURSOR FOR SELECT id FROM company;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_end=1;
OPEN curcompany;
cycle:  LOOP
FETCH curcompany INTO id_cur;
IF is_end THEN LEAVE cycle;
END IF;
IF EXISTS(SELECT 1 FROM company_investment WHERE investment_id = id_cur) THEN
SELECT SUM(amount) into new_raised FROM company_investment WHERE investment_id = id_cur GROUP BY investment_id;
ELSE
SET new_raised = 0;
END IF;
UPDATE company SET raised = new_raised WHERE id=id_cur;
END LOOP cycle;
CLOSE curcompany;
END;//
