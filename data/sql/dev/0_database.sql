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
    word_status TINYINT DEFAULT 0 NOT NULL,
    -- word_status:
    --  0 => The word is valid
    --  1 => The word is deleted
    PRIMARY KEY (word_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ALTER TABLE tomara.words ADD FULLTEXT index_ft_words_word_eng(word_eng);

/*CREATE TABLE tomara.updates (
    update_id INT NOT NULL AUTO_INCREMENT,
    word_id INT,
    update_type TINYINT DEFAULT 0,
    PRIMARY KEY (update_id),
    FOREIGN KEY (word_id) REFERENCES words(word_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;*/
