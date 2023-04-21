SELECT
	wh.history_id, wh.history_action_type,
	w.word_id, w.word_geo, w.word_eng, w.frequency
FROM tomara.words_history wh
LEFT JOIN tomara.words w ON w.word_id = wh.word_id
WHERE wh.history_id > :sql_last_value
  AND wh.history_time < NOW()
ORDER BY wh.history_id