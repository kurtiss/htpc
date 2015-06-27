version: 1 

remote - "Remote":
	bool nolocalauth : "No authentication on local connections" = True
	bool activated : "Activated" = True
	int port : "Port" = 7227
	ip listenaddr : "Adress" = {{ PYLOAD_REMOTE_PORT }}

log - "Log":
	int log_size : "Size in kb" = 100
	folder log_folder : "Folder" = /config/log
	bool file_log : "File Log" = True
	int log_count : "Count" = 5
	bool log_rotate : "Log Rotate" = True

permission - "Permissions":
	str group : "Groupname" = users
	bool change_dl : "Change Group and User of Downloads" = True
	bool change_file : "Change file mode of downloads" = True
	str user : "Username" = nobody
	str file : "Filemode for Downloads" = 0660
	bool change_group : "Change group of running process" = False
	str folder : "Folder Permission mode" = 0770
	bool change_user : "Change user of running process" = False

general - "General":
	en;de;fr;it;es;nl;sv;ru;pl;cs;sr;pt_BR language : "Language" = en
	folder download_folder : "Download Folder" = {{ PYLOAD_GENERAL_DOWNLOAD_FOLDER }}
	bool checksum : "Use Checksum" = False
	bool folder_per_package : "Create folder for each package" = False
	bool debug_mode : "Debug Mode" = False
	int min_free_space : "Min Free Space (MB)" = 200
	int renice : "CPU Priority" = 0

ssl - "SSL":
	file cert : "SSL Certificate" = ssl.crt
	bool activated : "Activated" = True
	file key : "SSL Key" = ssl.key

webinterface - "Webinterface":
	str template : "Template" = default
	bool activated : "Activated" = True
	str prefix : "Path Prefix" = 
	builtin;threaded;fastcgi;lightweight server : "Server" = lightweight
	ip host : "IP" = 0.0.0.0
	bool https : "Use HTTPS" = False
	int port : "Port" = {{ PYLOAD_WEBINTERFACE_PORT }}

proxy - "Proxy":
	str username : "Username" = None
	bool proxy : "Use Proxy" = False
	str address : "Address" = "localhost"
	password password : "Password" = None
	http;socks4;socks5 type : "Protocol" = http
	int port : "Port" = {{ PYLOAD_PROXY_PORT }}

reconnect - "Reconnect":
	time endTime : "End" = 0:00
	bool activated : "Use Reconnect" = False
	str method : "Method" = None
	time startTime : "Start" = 0:00

download - "Download":
	int max_downloads : "Max Parallel Downloads" = {{ PYLOAD_DOWNLOAD_MAX_DOWNLOADS }}
	bool limit_speed : "Limit Download Speed" = False
	str interface : "Download interface to bind (ip or Name)" = None
	bool skip_existing : "Skip already existing files" = False
	int max_speed : "Max Download Speed in kb/s" = -1
	bool ipv6 : "Allow IPv6" = False
	int chunks : "Max connections for one download" = {{ PYLOAD_DOWNLOAD_CHUNKS }}

downloadTime - "Download Time":
	time start : "Start" = 0:00
	time end : "End" = 0:00
