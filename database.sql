CREATE DATABASE IF NOT EXISTS village_project
    CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

USE village_project;

CREATE TABLE IF NOT EXISTS `settings`
(
    settings_option VARCHAR(255) NOT NULL,
    settings_value  VARCHAR(255) NULL,
    UNIQUE KEY unique_settings_option (settings_option)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `user`
(
    user_email                    VARCHAR(255)                        NOT NULL,
    user_lastname                 VARCHAR(255)                        NOT NULL,
    user_firstname                VARCHAR(255)                        NOT NULL,
    user_address                  text                                NOT NULL,
    user_birth_date               DATE                                NOT NULL,
    user_password                 VARCHAR(255)                        NOT NULL,
    user_status                   ENUM ('pending','active','deleted') NOT NULL DEFAULT 'pending',
    user_role                     ENUM ('user','moderator','admin')   NOT NULL DEFAULT 'user',
    user_remember_token           VARCHAR(255),
    user_confirmation_email_token VARCHAR(255),
    PRIMARY KEY (user_email)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `comment`
(
    comment_id     INT                                 NOT NULL AUTO_INCREMENT,
    comment_text   TEXT                                NOT NULL,
    comment_date   TIMESTAMP                           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    comment_status ENUM ('draft','pending','approved') NOT NULL DEFAULT 'draft',
    proposition_id INT                                 NOT NULL,
    user_email     VARCHAR(255)                        NOT NULL,
    PRIMARY KEY (comment_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `cycle`
(
    cycle_id    INT  NOT NULL AUTO_INCREMENT,
    cycle_start DATE NOT NULL,
    PRIMARY KEY (cycle_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vote`
(
    vote_points    ENUM ('1','2','3') NOT NULL DEFAULT '1',
    vote_date      TIMESTAMP          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_email     VARCHAR(255)       NOT NULL,
    proposition_id INT                NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `category`
(
    category_id          INT          NOT NULL AUTO_INCREMENT,
    category_name        VARCHAR(255) NOT NULL,
    category_description TEXT,
    PRIMARY KEY (category_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `proposition`
(
    proposition_id          INT                                            NOT NULL AUTO_INCREMENT,
    proposition_status      ENUM ('draft','pending','approved','declined') NOT NULL DEFAULT 'draft',
    proposition_title       VARCHAR(255)                                   NOT NULL,
    proposition_description TEXT                                           NOT NULL,
    proposition_date        TIMESTAMP                                      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_email              VARCHAR(255)                                   NOT NULL,
    cycle_id                INT                                            NOT NULL,
    category_id             INT                                            NOT NULL,
    PRIMARY KEY (proposition_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `media`
(
    media_id       INT          NOT NULL AUTO_INCREMENT,
    media_path     VARCHAR(255) NOT NULL,
    proposition_id INT          NOT NULL,
    PRIMARY KEY (media_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

ALTER TABLE `proposition`
    ADD CONSTRAINT `fk_proposition_user_email` FOREIGN KEY (user_email) REFERENCES user (user_email),
    ADD CONSTRAINT `fk_proposition_cycle_id` FOREIGN KEY (cycle_id) REFERENCES cycle (cycle_id),
    ADD CONSTRAINT `fk_proposition_category_id` FOREIGN KEY (category_id) REFERENCES category (category_id);

ALTER TABLE `comment`
    ADD CONSTRAINT `fk_comment_user_email` FOREIGN KEY (user_email) REFERENCES user (user_email),
    ADD CONSTRAINT `fk_comment_proposition_id` FOREIGN KEY (proposition_id) REFERENCES proposition (proposition_id) ON DELETE CASCADE;

ALTER TABLE `vote`
    ADD CONSTRAINT `fk_vote_user_email` FOREIGN KEY (user_email) REFERENCES user (user_email),
    ADD CONSTRAINT `fk_vote_proposition_id` FOREIGN KEY (proposition_id) REFERENCES proposition (proposition_id) ON DELETE CASCADE,
    ADD UNIQUE `unique_vote` (`user_email`, `proposition_id`);

ALTER TABLE `media`
    ADD CONSTRAINT `fk_media_proposition_id` FOREIGN KEY (proposition_id) REFERENCES proposition (proposition_id) ON DELETE CASCADE;


# Insert data
INSERT INTO `user` (`user_email`, `user_lastname`, `user_firstname`, `user_address`, `user_birth_date`, `user_password`,
                    `user_status`, `user_role`, `user_remember_token`, `user_confirmation_email_token`)
VALUES ('mourat@boutry.me', 'Mourat', 'Boutry', '10 bd Carlone', '2022-06-03',
        '$2y$10$wnPWwXcv9.BA4sAJ06UOxuDr8GLNpxdkck6Ir8p1KhPCndIAkLGWO', 'active', 'user',
        '$2y$10$wnPWwXcv9.BA4sAJ06UOxuDr8GLNpxdkck6Ir8p1KhPCndIAkLGWO',
        '$2y$10$wnPWwXcv9.BA4sAJ06UOxuDr8GLNpxdkck6Ir8p1KhPCndIAkLGWO');

INSERT INTO `category` (`category_id`, `category_name`, `category_description`)
VALUES (1, 'Hymne', 'Choisir un hymne de village');

INSERT INTO `cycle` (`cycle_start`)
VALUES ('2022-06-29');

INSERT INTO `proposition` (`proposition_id`, `proposition_status`, `proposition_title`, `proposition_description`,
                           `proposition_date`, `user_email`, `cycle_id`, `category_id`)
VALUES (1, 'draft', 'Bus', 'Acheter deuxieme bus', CURRENT_TIMESTAMP, 'mourat@boutry.me', '1', '1');

INSERT INTO `media` (`media_id`, `media_path`, `proposition_id`)
VALUES (1, '/toto/tata/image.jpg', 1),
       (2, '/toto/tata/image2.jpg', 1);

INSERT INTO `vote` (`vote_points`, `vote_date`, `user_email`, `proposition_id`)
VALUES ('1', CURRENT_DATE, 'mourat@boutry.me', 1);

INSERT INTO `comment` (`comment_id`, `comment_text`, `comment_date`, `comment_status`, `proposition_id`, `user_email`)
VALUES (1, 'Nimporte quoi!', CURRENT_TIMESTAMP, 'approved', 1, 'mourat@boutry.me');

INSERT INTO `settings` (`settings_option`, `settings_value`)
VALUES ('site_name', 'Project village'),
       ('uploaded_media', '/uploads/');