# File Server

|STEPS||ElasticSearch|gmail|file_idx|OCR_SERVER|Method|
|---:|:---
|1|new email message (no attachment)|||||cron: ~/file_server all_gmail|
|2|(before insert/update to gmail/file_idx)|update w/ avail content||||trigger: fs_update_es|
|3|||new email content||||
|4|(after update/insert on gmail)|||transferred content||trigger: fs_update_file_idx_on_gmail_update|
|5|(after update/insert on file_idx)|||(a) metadata extracted, and, if pdf/image, then (b) sent to server for OCR processing;||trigger:  fs_process_files_in_file_idx (1st pass)|
|---
|6|(content sent via websocket)||||(A) captures document through websocket upon properly initialization and saves to designated directory; (B) a document workflow begins at said designated directory and ends with communicating document content back through document source websocket;||
|7|(content received via websocket and file_idx updated)||||C) upon receiving all content and concluding with a unique close-socket signal, nginx saves the processed and suffixed-document with the original and updates the status of document in the file_idx table via an upstream pgsql webserver; (D) the status update again triggers 'fs_process_files_in_file_idx'"||
|---
|8|(after update/insert on file_idx)|||(c) OCR content is extracted and added to DB||trigger:  fs_process_files_in_file_idx (2nd pass)|


## Install
sudo apt-get update
sudo apt-get install -y tesseract-ocr
pip install pypdfocr

### Integrations

- Gmail
- MDScanner
- ElasticSearch
- Kibana


## TODO LIST
- [ ] clean up triggers and remove debugging cmds
- [ ] re-capture all gmail and compare
- [ ] add non-pdf file-type support
- [ ] batch process gmail from tmp tbl to file_idx REMAINING
- [ ] batch process scans with cron to regularly add new entries
- [ ] create trigger for scans
- [x] improve reliability of file_server
- [x] switch from syslog-ng to rsyslog (to improve monitoring)
- [x] integrate ElasticSearch & Kibana
- [x] trigger on file_idx update -> relay to ES
- [x] trigger on gmail update -> relay to ES
- [x] trigger on file_idx insert -> relay to ES
- [x] trigger on gmail insert -> relay to ES
- [x] create new tmp table of all attachments
    - [x] remove any duplicate or stagnant attachments
    - [x] identify attachments with uploaded content
    - [x] batch process attachments from tmp tbl to file_idx FIRST 1000
- [x] trigger on new gmail for adding all attachments to queue 
- [x] pypdfocr integration and trigger for running OCR
- [x] trigger for updating pdf content if available
- [x] trigger for pulling metadata on each attachment
- [x] gmail/postgres sync cron, including attachment downloads