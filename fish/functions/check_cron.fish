function check_cron
 ps -ef | grep cron | grep -v grep
end
