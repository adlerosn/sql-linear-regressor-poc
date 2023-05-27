linear_regressions.csv: db.sqlite3
	sqlite3 db.sqlite3 -csv -header "select * from linear_regressions" > linear_regressions.csv

db.sqlite3: athlete_events.csv
	python tosqlite.py athlete_events.csv
	time sqlite3 db.sqlite3 < query1.sql
	time sqlite3 db.sqlite3 < query2.sql
athlete_events.csv: Olympics_data.zip
	unzip -p Olympics_data.zip athlete_events.csv > athlete_events.csv
Olympics_data.zip:
	wget https://techtfq.com/s/Olympics_data.zip
clean:
	rm -f Olympics_data.zip
	rm -f athlete_events.csv
	rm -f db.sqlite3
	rm -f linear_regressions.csv