-- Database --

-- Database should be created in docker-compose
CREATE DATABASE IF NOT EXISTS tomara;

-- Charset should be set in docker-compose
ALTER DATABASE tomara CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Tables --

CREATE TABLE tomara.words (
    word_id INT NOT NULL AUTO_INCREMENT,
    word_geo VARCHAR(255) NOT NULL,
    word_eng VARCHAR(255) NOT NULL,
    frequency INT DEFAULT 1 NOT NULL,
    PRIMARY KEY (word_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE tomara.words ADD FULLTEXT index_ft_words_word_eng(word_eng);


CREATE TABLE tomara.words_history (
    history_id BIGINT NOT NULL AUTO_INCREMENT,
    word_id INT NOT NULL,
    history_action_type ENUM('insert','update','delete') DEFAULT NULL,
    history_time TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (history_id),
    FOREIGN KEY (word_id) REFERENCES words(word_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;


-- Triggers --

DELIMITER ;;
CREATE TRIGGER words_trigger_after_insert AFTER INSERT ON tomara.words
FOR EACH ROW INSERT INTO tomara.words_history
SET history_action_type = 'insert',
    word_id = NEW.word_id
;;


DELIMITER ;;
CREATE TRIGGER words_trigger_after_delete AFTER DELETE ON tomara.words
FOR EACH ROW INSERT INTO tomara.words_history
SET history_action_type = 'delete',
    word_id = OLD.word_id
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
