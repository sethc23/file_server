# File Server




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