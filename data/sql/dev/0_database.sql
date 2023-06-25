--
--
-- Database --
--
--


-- Database should be created in docker-compose
CREATE DATABASE IF NOT EXISTS tomara;

-- Charset should be set in docker-compose
ALTER DATABASE tomara CHARACTER SET utf8 COLLATE utf8_general_ci;

--
-- Tables
--

CREATE TABLE tomara.words (
    word_id INT NOT NULL AUTO_INCREMENT,
    word_geo VARCHAR(255) NOT NULL,
    word_eng VARCHAR(255) NOT NULL,
    frequency INT DEFAULT 1 NOT NULL,
    PRIMARY KEY (word_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE tomara.words ADD FULLTEXT index_ft_words_word_geo(word_geo);
ALTER TABLE tomara.words ADD FULLTEXT index_ft_words_word_eng(word_eng);


-- This table is used by application to isolate deleted words from valid ones --
CREATE TABLE tomara.words_deleted (
    deletion_id INT NOT NULL AUTO_INCREMENT,
    del_word_id INT NOT NULL,
    del_word_geo VARCHAR(255) NOT NULL,
    del_word_eng VARCHAR(255) NOT NULL,
    PRIMARY KEY (deletion_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE tomara.words_deleted ADD FULLTEXT index_ft_words_deleted_del_word_geo(del_word_geo);
ALTER TABLE tomara.words_deleted ADD FULLTEXT index_ft_words_deleted_del_word_eng(del_word_eng);


-- Those tables store offers about adding or deleting new words
CREATE TABLE tomara.words_offer_add_store (
    offer_id INT NOT NULL AUTO_INCREMENT,
    word_geo VARCHAR(255) NOT NULL,
    word_eng VARCHAR(255) NOT NULL,
    PRIMARY KEY (offer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE tomara.words_offer_add_store ADD FULLTEXT index_ft_words_offer_add_store_word_geo(word_geo);

CREATE TABLE tomara.words_offer_add (
    add_offer_id INT NOT NULL AUTO_INCREMENT,
    add_offer_word_id INT NOT NULL,
    add_offer_time TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (add_offer_id),
    FOREIGN KEY (add_offer_word_id) REFERENCES words_offer_add_store(offer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE tomara.words_offer_delete (
    del_offer_id INT NOT NULL AUTO_INCREMENT,
    del_offer_word_id INT NOT NULL,
    del_offer_time TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (del_offer_id),
    FOREIGN KEY (del_offer_word_id) REFERENCES words(word_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;


--
-- This table is used by logstash to track changes on main tables
--

CREATE TABLE tomara.words_history (
    history_id BIGINT NOT NULL AUTO_INCREMENT,
    word_id INT NOT NULL,
    history_action_type ENUM('insert','update','delete') DEFAULT NULL,
    history_time TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (history_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;


--
-- Other tables
--

CREATE TABLE tomara.reviews (
    review_id INT NOT NULL AUTO_INCREMENT,
    review_content VARCHAR(1023) NOT NULL,
    review_time TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (review_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;


--
-- Triggers
--

DELIMITER ;;
CREATE TRIGGER words_trigger_after_insert AFTER INSERT ON tomara.words
FOR EACH ROW INSERT INTO tomara.words_history
SET history_action_type = 'insert',
    word_id = NEW.word_id
;;


DELIMITER ;;
CREATE TRIGGER words_trigger_after_delete AFTER DELETE ON tomara.words
FOR EACH ROW BEGIN
    INSERT INTO tomara.words_history
    SET history_action_type = 'delete',
        word_id = OLD.word_id;

    INSERT INTO tomara.words_deleted
    SET del_word_id = OLD.word_id,
        del_word_geo = OLD.word_geo,
        del_word_eng = OLD.word_eng;
END
;;


DELIMITER ;;
CREATE TRIGGER words_trigger_after_update AFTER UPDATE ON tomara.words
FOR EACH ROW IF NEW.word_id = OLD.word_id THEN
    INSERT INTO tomara.words_history
    SET history_action_type = 'update',
        word_id = OLD.word_id;
ELSE
    INSERT INTO tomara.words_history
    SET history_action_type = 'delete',
        word_id = OLD.word_id;
    INSERT INTO tomara.words_history
    SET history_action_type = 'insert',
        word_id = NEW.word_id;
END IF
;;
